export PATH="$HOME/.local/bin:$PATH"
cd ~/dsan6000-hw07
cat > /tmp/keepalive.py <<'PY'
import socket, subprocess, time
from pyspark.sql import SparkSession
ip = subprocess.check_output(["hostname","-I"]).decode().split()[0]
spark = (SparkSession.builder.appName("UNSC_Speeches").master(f"spark://{ip}:7077")
         .config("spark.jars.packages","org.apache.hadoop:hadoop-aws:3.5.0").getOrCreate())
print("cores", spark.sparkContext.defaultParallelism, flush=True)
spark.range(10_000_000).selectExpr("sum(id)").collect()
time.sleep(1800)
PY
pkill -f keepalive.py 2>/dev/null; sleep 1
setsid nohup uv run python /tmp/keepalive.py > /tmp/keepalive.log 2>&1 < /dev/null &
for i in $(seq 1 30); do grep -q "^cores" /tmp/keepalive.log && break; sleep 3; done
grep "^cores" /tmp/keepalive.log || tail -5 /tmp/keepalive.log
