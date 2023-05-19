# CODEX v0.0.1

import os
import openai
import PyPDF2
import sys
import tiktoken

openai.api_key = os.getenv("OPENAI_API_KEY")


#####################     Funtions      ###################
def summarize_pdf(path):
    pdf_text = read_pdf(path)
    prompt = "Summarize this for a high school student, make sure all sentences are grammatical and not cut off, strip whitespace and newlines:\n\n " + truncate_string(pdf_text)
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=64,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )

    return response.choices[0].message.content

def read_pdf(path):
    with open(path, 'rb') as f:
        pdf_reader = PyPDF2.PdfReader(f)
        text = ''
        for page_num in range(len(pdf_reader.pages)):
            page = pdf_reader.pages[page_num]
            text += page.extract_text()
        return text

def truncate_string(input_string):
    tokens = num_tokens_from_string(input_string, "cl100k_base")
    if tokens <= 4000:
        return input_string
    else:
        words = input_string.split()
        reduced_words = words[:len(words)//2]
        input_string = " ".join(reduced_words)
        return truncate_string(input_string)

def num_tokens_from_string(string: str, encoding_name: str) -> int:
    """Returns the number of tokens in a text string."""
    encoding = tiktoken.get_encoding(encoding_name)
    num_tokens = len(encoding.encode(string))
    return num_tokens


#####################     Main          ###################
# You can run this file with:   python3 summaryze.py <pdf_path>
# The output is the summary of the pdf
pdf_path = sys.argv[1]
result = summarize_pdf(pdf_path)
print(result)
