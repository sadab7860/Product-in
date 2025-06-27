const express = require('express');
const multer = require('multer');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
const upload = multer({ dest: 'uploads/' });

app.post('/search', upload.single('image'), async (req, res) => {
  try {
    const image = req.file;
    const imageData = require('fs').readFileSync(image.path);

    const response = await axios({
      method: 'post',
      url: 'https://api.bing.microsoft.com/v7.0/images/visualsearch',
      headers: {
        'Ocp-Apim-Subscription-Key': process.env.BING_API_KEY,
        'Content-Type': 'multipart/form-data',
      },
      data: {
        image: imageData,
      },
    });

    // Process API response
    const results = response.data?.tags?.[0]?.actions || [];
    const firstProduct = results.find(act => act.actionType === "VisualSearch");

    if (firstProduct && firstProduct.data && firstProduct.data.value.length > 0) {
      const product = firstProduct.data.value[0];
      return res.json({ result: product.hostPageUrl });
    } else {
      return res.json({ result: 'Sorry, product not found.' });
    }

  } catch (err) {
    console.error(err);
    res.status(500).json({ result: 'Error processing request.' });
  }
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});
