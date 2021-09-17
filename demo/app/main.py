from flask import Flask
app = Flask(__name__)

import tensorflow as tf
with tf.device('/gpu:0'):
  a = tf.constant([1.0,2.0,3.0,4.0,5.0,6.0], shape=[2,3],name='a')
  b = tf.constant([1.0,2.0,3.0,4.0,5.0,6.0], shape=[3,2],name='b')
  c = tf.matmul(a,b)

@app.route("/")
def hello():
  out = "Hello World from Flask with TensorFlow " + \
        "in a uWSGI Nginx Docker container " + \
        "with Python 3.5\n\n"

  out = out + "[[1.0,2.0,3.0][4.0,5.0,6.0]] * [[1.0,2.0][3.0,4.0][5.0,6.0]] = "

  with tf.Session() as sess:
    out = out + str(sess.run(c))

  return out 

if __name__ == "__main__":
  app.run(host='0.0.0.0', debug=True, port=80)
    