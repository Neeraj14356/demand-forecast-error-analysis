
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# Output folder for processed CSVs
OUTPUT_DIR = Path(
    r"D:\Project\Demand Forecasting Analysis\01_Datasets\processed"
)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# MySQL connection details
USER = "root"
PASSWORD = "Neer@j143"
HOST = "localhost"
PORT = 3306
DATABASE = "demand_forecasting"

url = URL.create(
    drivername="mysql+pymysql",
    username=USER,
    password=PASSWORD,
    host=HOST,
    port=PORT,
    database=DATABASE,
)

engine = create_engine(url)

# Existing MySQL tables and output CSV names
tables = [
    "fact_sales",
    "dim_stores",
    "dim_oil_prices",
    "dim_holidays_events",
    "fact_transactions",
]

try:
    with engine.connect() as connection:
        print("Connected to MySQL successfully!")

    for table in tables:
        try:
            df = pd.read_sql_table(table, con=engine)

            output_file = OUTPUT_DIR / f"{table}.csv"
            df.to_csv(output_file, index=False)

            print(
                f"Exported {table}: {len(df):,} rows "
                f"-> {output_file.name}"
            )

        except Exception as error:
            print(f"Could not export {table}: {error}")

finally:
    engine.dispose()

print("CSV export process finished.")
