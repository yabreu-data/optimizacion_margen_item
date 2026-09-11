# -*- coding: utf-8 -*-
"""
yenni
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pandas as pd


load_dotenv()

def get_engine():
    """Crea la conexión a MySQL usando credenciales del archivo .env (nunca hardcodeadas)."""
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "3306")
    database = os.getenv("DB_NAME")
    connection_str = f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"
    return create_engine(connection_str)

def cargar_margen_por_venta() -> pd.DataFrame:
    """Carga la vista margen_por_venta creada en 04_calculo_margen.sql."""
    engine = get_engine()
    query = "SELECT * FROM margen_por_venta;"
    return pd.read_sql(query, engine)

if __name__ == "__main__":
    df = cargar_margen_por_venta()
    print(f"Filas cargadas: {df.shape[0]}")
    print(df.head())


