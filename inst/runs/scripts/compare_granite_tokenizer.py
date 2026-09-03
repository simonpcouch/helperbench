import argparse
import json
import subprocess
import sys

from transformers import AutoTokenizer


parser = argparse.ArgumentParser()
parser.add_argument("gguf")
args = parser.parse_args()

payload = json.load(sys.stdin)
tokenizer = AutoTokenizer.from_pretrained("ibm-granite/granite-4.2-8b")
rendered = tokenizer.apply_chat_template(
    payload["messages"],
    tools=payload["tools"],
    add_generation_prompt=True,
    tokenize=False,
    reasoning_effort="medium",
)
official_tokens = len(tokenizer(rendered, add_special_tokens=False).input_ids)

result = subprocess.run(
    [
        "llama-tokenize",
        "--model",
        args.gguf,
        "--stdin",
        "--no-bos",
        "--show-count",
        "--log-disable",
    ],
    input=rendered,
    text=True,
    capture_output=True,
    check=True,
)
tokenizer_output = result.stdout + "\n" + result.stderr
count_line = next(
    line
    for line in reversed(tokenizer_output.splitlines())
    if "total number of tokens" in line.lower()
)
gguf_tokens = int(count_line.rsplit(" ", 1)[-1])

print(json.dumps({
    "rendered_characters": len(rendered),
    "rendered_bytes": len(rendered.encode()),
    "official_hf_tokens": official_tokens,
    "ollama_gguf_tokens": gguf_tokens,
    "difference": gguf_tokens - official_tokens,
}, indent=2))
