const db = require('../db/db');

exports.getInventory = (req, res) => {
    db.query('SELECT * FROM inventory', (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json(results);
        }
    });
};

exports.addProduct = (req, res) => {
    const { name, description, price, stock } = req.body;
    db.query('INSERT INTO inventory (name, description, price, stock) VALUES (?, ?, ?, ?)', [name, description, price, stock], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(201).send({ id: results.insertId });
        }
    });
};

exports.updateProduct = (req, res) => {
    const productId = req.params.id;
    const { name, description, price, stock } = req.body;
    db.query('UPDATE inventory SET name = ?, description = ?, price = ?, stock = ? WHERE id = ?', [name, description, price, stock, productId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(200).send(results);
        }
    });
};

exports.deleteProduct = (req, res) => {
    const productId = req.params.id;
    db.query('DELETE FROM inventory WHERE id = ?', [productId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(204).send();
        }
    });
};