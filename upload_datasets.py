
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# Dataset folder
DATA_DIR = Path(
    r"/01_Datasets/raw"
)

# MySQL credentials
USER = "root"
PASSWORD = "Neer@j143"
HOST = "localhost"
PORT = 3306
DATABASE = "demand_forecasting"

# MySQL connection
url = URL.create(
    drivername="mysql+pymysql",
    username=USER,
    password=PASSWORD,
    host=HOST,
    port=PORT,
    database=DATABASE,
)

engine = create_engine(url)

# CSV filename : MySQL table name
datasets = {
    "train.csv": "raw_train",
    "test.csv": "raw_test",
    "stores.csv": "raw_stores",
    "oil.csv": "raw_oil",
    "holidays_events.csv": "raw_holidays_events",
    "transactions.csv": "raw_transactions",
    "sample_submission.csv": "raw_sample_submission",
}

try:
    # Test MySQL connection
    with engine.connect() as connection:
        print("MySQL connected successfully!")

    for filename, table_name in datasets.items():
        file_path = DATA_DIR / filename

        if not file_path.exists():
            print(f"Skipped (file not found): {filename}")
            continue

        df = pd.read_csv(file_path)

        # Convert date columns
        for column in df.columns:
            if column.lower() == "date":
                df[column] = pd.to_datetime(
                    df[column], errors="coerce"
                ).dt.date

        # Create/replace the destination table
        df.to_sql(
            name=table_name,
            con=engine,
            if_exists="replace",
            index=False,
            chunksize=5000,
        )

        print(
            f"Uploaded {filename}: "
            f"{len(df):,} rows -> {table_name}"
        )

    print("Dataset upload process finished!")

finally:
    engine.dispose()
