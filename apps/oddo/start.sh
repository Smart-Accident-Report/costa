#!/bin/bash

echo "🚀 Starting Oddo Database Manager..."

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
until python -c "
import psycopg2
import os
try:
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=os.getenv('DB_PORT', '5432'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'postgres123'),
        database=os.getenv('DB_NAME', 'costa')
    )
    conn.close()
    print('✅ Database connected!')
except Exception as e:
    print(f'❌ Database connection failed: {e}')
    exit(1)
"; do
    echo "⏳ Database not ready, waiting..."
    sleep 2
done

echo "🎯 Database ready! Starting Oddo app..."
exec python app.py
