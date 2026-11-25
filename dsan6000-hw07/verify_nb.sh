cd ~/dsan6000-hw07 && python3 -c '
import json
nb=json.load(open("DSAN6000_HW07.ipynb"))
errs=0
for i,c in enumerate(nb["cells"]):
    if c["cell_type"]!="code": continue
    for o in c.get("outputs",[]):
        if o.get("output_type")=="error": errs+=1; print("ERROR cell",i,o.get("ename"))
        t="".join(o.get("text",[])) if o.get("output_type")=="stream" else ""
        for l in t.splitlines():
            if "Available cores" in l or "partitions" in l or "Number of unique" in l or "Master node private" in l or l.startswith("spark://"): print(l)
print("error outputs:",errs)'
