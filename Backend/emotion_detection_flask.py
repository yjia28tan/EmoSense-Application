import tensorflow as tf
from flask import Flask, request, jsonify
from PIL import Image
import numpy as np
import io

app = Flask(__name__)

# Load the model without compiling
model = tf.keras.models.load_model(
    r'C:\Users\User\OneDrive\Documents\YiJia\INTI\FYP\fyp\Backend\model\72_accuracy_model_resnet_4group.h5',
    compile=False
)

# Recompile the model with the correct loss function
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
    loss=tf.keras.losses.CategoricalCrossentropy(reduction='sum_over_batch_size'),
    metrics=[tf.keras.metrics.CategoricalAccuracy(name="accuracy"),
             tf.keras.metrics.TopKCategoricalAccuracy(k=4, name="top_k_accuracy")]
)

def preprocess_image(image):
    """Preprocess the image for the model."""
    # Resize and preprocess the image
    image = image.resize((48, 48))
    image_array = np.array(image) / 255.0
    image_array = np.expand_dims(image_array, axis=0)
    return image_array

@app.route('/predict', methods=['POST'])
def predict():
    """Predict the emotion from an uploaded image."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        image = Image.open(io.BytesIO(file.read()))
        image_array = preprocess_image(image)
        predictions = model.predict(image_array)
        class_idx = np.argmax(predictions, axis=1)[0]
        class_names = ['Angry', 'Happy', 'Sad', 'Neutral']  # Adjust as needed
        detected_emotion = class_names[class_idx]
        print(detected_emotion)

        return jsonify({'detected_emotion': detected_emotion}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
