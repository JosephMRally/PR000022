#!/bin/bash

# Function to start Jupyter Notebook
start_jupyter() {
    echo "Starting Spark History Server..."
    echo "Starting Jupyter Notebook..."
    $SPARK_HOME/sbin/start-history-server.sh && jupyter notebook --ip=0.0.0.0 --port=4041 --no-browser --NotebookApp.token='' --NotebookApp.password=''
}

# Function to start Spark Shell
start_spark_shell() {
    echo "Starting Spark Shell..."
    $SPARK_HOME/sbin/start-history-server.sh && spark-shell
}

# Function to start PySpark Shell
start_pyspark_shell() {
    echo "Starting PySpark Shell..."
    unset PYSPARK_DRIVER_PYTHON
    unset PYSPARK_DRIVER_PYTHON_OPTS
    $SPARK_HOME/sbin/start-history-server.sh && pyspark 
        --packages io.delta:delta-spark 
        --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" 
        --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
        --conf spark.sql.catalogImplementation=hive        
}

# Initialize the Hive Metastore schema if not already initialized
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
if schematool -dbType postgres -info | grep -q "Schema version"; then
    echo "Hive schema already initialized."
else
    echo "Initializing Hive schema..."
    schematool -dbType postgres -initSchema || echo "Schema already initialized or encountered an error"
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# Main logic to decide which service to start
case "$1" in
    jupyter)
        start_jupyter
        ;;
    spark-shell)
        start_spark_shell
        ;;
    pyspark)
        start_pyspark_shell
        ;;
    *)
        echo "Usage: $0 {jupyter|spark-shell|pyspark}"
        exit 1
        ;;
esac
