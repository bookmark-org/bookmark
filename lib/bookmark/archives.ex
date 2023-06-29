defmodule Bookmark.Archives do
  @moduledoc """
  The Archives context.
  """

  require Logger
  import Ecto.Query, warn: false
  alias Bookmark.Repo
  alias Bookmark.Archives.Archive
  alias Bookmark.Archives
  alias Bookmark.Utils

  @doc """
  Returns the list of archives.

  ## Examples

      iex> list_archives()
      [%Archive{}, ...]

  """
  def list_archives do
    Repo.all(Archive)
  end

  def get_archive_ids_by_user(user) do
    query =
      from a in "archives",
        where: a.user_id == ^user.id,
        select: a.name

    Repo.all(query)
  end

  def get_archives_by_user(user) do
    Archive |> where(user_id: ^user.id) |> Repo.all()
  end

  def get_topn_archive_ids_by_user(user, n) do
    query =
      from a in "archives",
        where: a.user_id == ^user.id,
        select: a.name,
        limit: ^n,
        order_by: [desc: a.id]

    Repo.all(query)
  end

  @doc """
  Creates a archive.

  ## Examples

      iex> create_archive(%{field: value}, user)
      {:ok, %Archive{}}

      iex> create_archive(%{field: bad_value}, user)
      {:error, %Ecto.Changeset{}}

  """
  def create_archive(
        attrs,
        user
      ) do
    user = user || Bookmark.Accounts.get_user_by_email("anonymous@bookmark.org")

    {:ok, archive} =
      %Archive{}
      |> Archive.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert()

    add_summary(archive)
  end


  def get_title(archive_id) do
    list = index_data(archive_id)

    String.slice(list["title"], 0..199)
  end

  def add_summary(archive) do
    {:ok, summary} = get_summary(archive)

    archive
    |> Archive.changeset(%{summary: summary})
    |> Repo.update()
  end

  # Archivebox, create archives

  # Returns a list of {:ok, %Archive}
  def bulk_archives(url_list, user, caller_pid \\ nil) do
    delay = get_bulk_archive_delay()

    tasks = Task.async_stream(
      Enum.with_index(url_list), fn {url, index} ->
          try do
            :timer.sleep(index * delay)
            {:ok, archive} = Archives.archive_url(url, user)
            if caller_pid, do: Process.send(caller_pid, {:success, archive, url}, [:noconnect])
            {:ok, archive}
          rescue e ->
            if caller_pid, do: Process.send(caller_pid, {:fail, url, e}, [:noconnect])
            Logger.error(Exception.format(:error, e, __STACKTRACE__))
            {:error, e}
          end
      end,
      timeout: :infinity
      )

    Logger.info("The following tasks were created: #{inspect(tasks)}")
    Enum.each(tasks, fn t -> Logger.info("Task result: #{inspect(t)}") end)
  end

  def archive_url(url, user) do
    if check_nsfw_domain(url) do
      {:error, :domain_not_allowed}
    else
      url = parse_url_if_is_image(url)
      archivebox(url, user)
    end
  end

  # Transforms image urls to Bookmark image viewer urls (expressed in Base64), which allows to archive them as HTML.
  # Examples:
  #   url = https://foo.com/ -> https://foo.com/
  #   url = https://foo.com/image.jpg -> bookmark.org/image?url={base_64(https://foo.com/image.jpg)}
  def parse_url_if_is_image(url) do
    %{path: path} = URI.parse(url)

    image_extensions = [".apng", ".avif", ".gif", ".jpg", ".jpeg", ".jfif", ".pjpeg", ".pjp", ".png",
    ".svg", ".webp", ".bmp", "ico", ".cur", ".tif", ".tiff"]

    if String.ends_with?(path || "", image_extensions) do
      encoded_url =
        url
        |> Utils.remove_query_string()
        |> Base.encode64()

      # TODO: Handle the base_path in prod mode, using the published domain
      base_path = "http://host.docker.internal:4000"
      image_viewer_path = BookmarkWeb.Router.Helpers.page_path(BookmarkWeb.Endpoint, :image_viewer, %{url: encoded_url})
      base_path <> image_viewer_path
    else
      url
    end
  end

  def archivebox(url, user) do
    url = add_timestamp(url)
    Logger.info("Executing: archivebox add #{url} ...")
    body = JSON.encode!(url: url)
    headers = %{"content-type" => "application/json"}
    response = Req.post(archivebox_url(), body: body, headers: headers, receive_timeout: 120_000)
    Logger.info("Executed: archivebox add #{url}")

    case response do
      {:ok, %Req.Response{status: 200, body: body}} ->
        result = body["result"]

        regex_result = Regex.run(~r/archive\/(.*)/, result)

        cond do
          String.contains?(result, "Extractor failed") ->
            cond do
              String.contains?(result, "404 Not Found") ->
                Logger.error(result)
                {:error, :page_not_found}
              String.contains?(result, "unable to resolve host address") ->
                Logger.error(result)
                {:error, :cant_be_reached}
              true ->
                Logger.error(result)
                {:error, :unexpected_error}
            end
          String.contains?(result, "Failed to parse") ->
            Logger.error(result)
            {:error, :failed_to_parse}
          String.contains?(result, "Found 0 new URLs not already in index") ->
            Logger.error(result)
            {:error, :already_exists}
          is_nil(regex_result) ->
            Logger.error(result)
            {:error, :unexpected_error}
          true ->
            Logger.debug(result)
            [_err, id] = String.split(List.first(regex_result), "archive/")
            create_archive(%{name: id, comment: "", title: Archives.get_title(id)}, user)
        end
      {:ok, %Req.Response{status: 500, body: body}} ->
        Logger.error(body)
        {:error, :internal_server_error}

      {:error, %{reason: :timeout}} ->
        {:error, :timeout_error}

      _ ->
        Logger.error("Archivebox response error: #{inspect(response)}")
        {:error, :unexpected_error}
    end
  end

  # This function is necessary to avoid the "URL already exists" archivebox error
  # https://duplicate-url.domain/page -> https://duplicate-url.domain/page#<unix_timestamp>
  def add_timestamp(url) do
    url <> "##{Integer.to_string(:os.system_time(:millisecond))}"
  end

  defp check_nsfw_domain(url) do
    domain = Utils.get_domain(url)

    blocked_domains =
      :bookmark
      |> :code.priv_dir()
      |> Path.join("/static/blocked_domains.txt")
      |> File.read!()
      |> String.split("\n", trim: true)

    Enum.find(blocked_domains, fn blocked_domain -> blocked_domain == domain end)
  end

  defp archivebox_url() do
    System.get_env("BOOKMARK_ARCHIVEBOX_URL") ||
      raise """
      environment variable BOOKMARK_ARCHIVEBOX_URL is missing.
      For example: archivebox:5001/add
      """
  end

  # Summary
  def get_summary(archive) do
    pdf_path = pdf_path(archive)

    try do
      Logger.info("Executing: python3 summarize.py #{pdf_path} ...")
      {output, 0} = System.cmd("python3", ["summarize.py", pdf_path], cd: File.cwd!)
      Logger.info("Executed: python3 summarize.py #{pdf_path}")
      {:ok, output}
    rescue e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      {:ok, "Summary not available"}
    end
  end


  # Utils
  def pdf_path(archive) do
    directory() <> "/archive/" <> archive.name <>  "/output.pdf"
  end

  def directory do
    case Application.get_env(:bookmark, :env) do
      :prod -> Application.app_dir(:bookmark, "priv/static/archive")
      _ -> File.cwd!() <> "/priv/static/archive"
    end
  end

  def index_data(archive_id) do
    file_path = Bookmark.Archives.directory() <> "/archive/" <> archive_id
    index_json = File.read!(file_path <> "/index.json")
    JSON.decode!(index_json)
  end

  # Delay expressed in milliseconds.
  # Returns the BOOKMARK_ARCHIVE_DELAY env variable or 300 as default
  def get_bulk_archive_delay() do
    if System.get_env("BOOKMARK_ARCHIVE_DELAY") do
      String.to_integer(System.get_env("BOOKMARK_ARCHIVE_DELAY"))
    else
      300
    end
  end
end
