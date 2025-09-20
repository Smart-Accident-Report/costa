from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import os
from dotenv import load_dotenv
import logging
import traceback

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Configuration
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')
app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db = SQLAlchemy(app)

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        # Test database connection
        result = db.engine.execute("SELECT 1")
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'message': 'Oddo app is running successfully'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e)
        }), 500

@app.route('/query', methods=['POST'])
def execute_query():
    """Execute SQL query on the database"""
    try:
        data = request.get_json()
        
        if not data or 'query' not in data:
            return jsonify({
                'error': 'Missing query parameter',
                'message': 'Please provide a SQL query in the request body'
            }), 400
        
        query = data['query'].strip()
        
        # Security check - prevent dangerous operations
        forbidden_keywords = ['DROP', 'DELETE', 'TRUNCATE', 'ALTER', 'CREATE', 'INSERT', 'UPDATE']
        query_upper = query.upper()
        
        if any(keyword in query_upper for keyword in forbidden_keywords):
            return jsonify({
                'error': 'Forbidden operation',
                'message': 'Only SELECT queries are allowed for safety'
            }), 403
        
        # Execute the query
        result = db.engine.execute(query)
        
        # Fetch results for SELECT queries
        if query_upper.startswith('SELECT'):
            rows = result.fetchall()
            columns = result.keys()
            
            # Convert to list of dictionaries
            data = []
            for row in rows:
                row_dict = {}
                for i, column in enumerate(columns):
                    row_dict[column] = row[i]
                data.append(row_dict)
            
            return jsonify({
                'success': True,
                'data': data,
                'count': len(data),
                'columns': list(columns)
            })
        else:
            return jsonify({
                'success': True,
                'message': 'Query executed successfully',
                'affected_rows': result.rowcount
            })
            
    except Exception as e:
        logger.error(f"Error executing query: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({
            'error': 'Query execution failed',
            'message': str(e)
        }), 500

@app.route('/tables', methods=['GET'])
def list_tables():
    """List all tables in the database"""
    try:
        query = """
        SELECT table_name, table_schema
        FROM information_schema.tables 
        WHERE table_schema = 'public'
        ORDER BY table_name;
        """
        
        result = db.engine.execute(query)
        tables = [{'name': row[0], 'schema': row[1]} for row in result.fetchall()]
        
        return jsonify({
            'success': True,
            'tables': tables,
            'count': len(tables)
        })
        
    except Exception as e:
        logger.error(f"Error listing tables: {str(e)}")
        return jsonify({
            'error': 'Failed to list tables',
            'message': str(e)
        }), 500

@app.route('/table/<table_name>/schema', methods=['GET'])
def get_table_schema(table_name):
    """Get schema information for a specific table"""
    try:
        query = """
        SELECT 
            column_name,
            data_type,
            is_nullable,
            column_default,
            character_maximum_length
        FROM information_schema.columns 
        WHERE table_name = %s AND table_schema = 'public'
        ORDER BY ordinal_position;
        """
        
        result = db.engine.execute(query, (table_name,))
        columns = []
        
        for row in result.fetchall():
            columns.append({
                'name': row[0],
                'type': row[1],
                'nullable': row[2] == 'YES',
                'default': row[3],
                'max_length': row[4]
            })
        
        return jsonify({
            'success': True,
            'table': table_name,
            'columns': columns,
            'count': len(columns)
        })
        
    except Exception as e:
        logger.error(f"Error getting table schema: {str(e)}")
        return jsonify({
            'error': 'Failed to get table schema',
            'message': str(e)
        }), 500

@app.route('/table/<table_name>/data', methods=['GET'])
def get_table_data(table_name):
    """Get data from a specific table with pagination"""
    try:
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 100, type=int)
        offset = (page - 1) * limit
        
        # Get total count
        count_query = f"SELECT COUNT(*) FROM {table_name}"
        count_result = db.engine.execute(count_query)
        total = count_result.fetchone()[0]
        
        # Get data with pagination
        data_query = f"SELECT * FROM {table_name} LIMIT {limit} OFFSET {offset}"
        result = db.engine.execute(data_query)
        
        rows = result.fetchall()
        columns = result.keys()
        
        # Convert to list of dictionaries
        data = []
        for row in rows:
            row_dict = {}
            for i, column in enumerate(columns):
                # Handle datetime and other special types
                value = row[i]
                if hasattr(value, 'isoformat'):
                    value = value.isoformat()
                row_dict[column] = value
            data.append(row_dict)
        
        return jsonify({
            'success': True,
            'table': table_name,
            'data': data,
            'pagination': {
                'page': page,
                'limit': limit,
                'total': total,
                'pages': (total + limit - 1) // limit
            },
            'columns': list(columns)
        })
        
    except Exception as e:
        logger.error(f"Error getting table data: {str(e)}")
        return jsonify({
            'error': 'Failed to get table data',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    host = os.getenv('HOST', '0.0.0.0')
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    
    logger.info(f"Starting Oddo App on {host}:{port}")
    app.run(host=host, port=port, debug=debug)
