const db = require('../db/db');

exports.getCustomer = (req, res) => {
    const customerId = req.params.id;
    db.query('SELECT * FROM customers WHERE id = ?', [customerId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json(results);
        }
    });
};

exports.createCustomer = (req, res) => {
    const { name, email, password } = req.body;
    db.query('INSERT INTO customers (name, email, password) VALUES (?, ?, ?)', [name, email, password], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(201).send({ id: results.insertId });
        }
    });
};

exports.updateCustomer = (req, res) => {
    const customerId = req.params.id;
    const { name, email, password } = req.body;
    db.query('UPDATE customers SET name = ?, email = ?, password = ? WHERE id = ?', [name, email, password, customerId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.status(200).send(results);
        }
    });
};