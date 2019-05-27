from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
import sys
import traceback
from sklearn.externals import joblib

app = Flask(__name__)


@app.route("/")
def test():
    return "Api Working!"


# Your API endpoint URL would consist /predict
@app.route('/predict', methods=['POST'])
def predict():
    if lr:
        try:
            json_ = request.json
            print(json_)
            query_df = pd.DataFrame(json_)
            query = pd.get_dummies(query_df)
            query = query.reindex(columns=model_columns, fill_value=0)
            prediction = list(lr.predict(query))
            return jsonify({'prediction': str(prediction)})

        except:
            return jsonify({'trace': traceback.format_exc()})

    else:
        print('Train the model first')
        return ('No model here to use')


if __name__ == '__main__':
    try:
        port = int(sys.argv[1])  # This is for a command-line argument
    except IndexError:
        port = 5000  # If no port provided, then the port will be set to 5000

    try:
        lr = joblib.load("model.pkl")
        print('Model loaded')
    except FileNotFoundError:
        print('Model file not found')

    model_columns = joblib.load("model_columns.pkl")
    print('Model columns loaded')

    # host of 0.0.0.0 for Gunicorn and debug-False
    app.run(host='0.0.0.0', port=port, debug=False)
