curl -s localhost:8080/json/ | python3 -c '
import sys, json
d = json.load(sys.stdin)
print("alive workers:", d["aliveworkers"], "| total cores:", d["cores"])
for w in d["workers"]: print(" ", w["host"], w["state"], w["cores"], "cores")'
