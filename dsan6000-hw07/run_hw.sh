set -e
export PATH="$HOME/.local/bin:$PATH"
command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
export PATH="$HOME/.local/bin:$PATH"
cd ~/dsan6000-hw07
uv sync -q
echo "== running notebook (this takes a few minutes) =="
uv run --with jupyter --with ipykernel jupyter nbconvert --to notebook --execute --inplace \
  --ExecutePreprocessor.timeout=1800 --ExecutePreprocessor.kernel_name=python3 DSAN6000_HW07.ipynb
ls -la affiliation_counts.csv && head -5 affiliation_counts.csv
echo HW_DONE
