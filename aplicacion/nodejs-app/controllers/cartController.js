const db = require('../db/db');

exports.getCart = (req, res) => {
    const userId = req.params.userId;
    db.query('SELECT * FROM cart WHERE user_id = ?', [userId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json(results);
        }
    });
};

exports.addToCart = (req, res) => {
    const userId = req.params.userId;
    const { productId, quantity } = req.body;
    db.query('INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)', [userId, productId, quantity], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(201).send({ id: results.insertId });
        }
    });
};

exports.removeFromCart = (req, res) => {
    const userId = req.params.userId;
    const productId = req.params.productId;
    db.query('DELETE FROM cart WHERE user_id = ? AND product_id = ?', [userId, productId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(204).send();
        }
    });
};