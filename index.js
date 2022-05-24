const fileUpload = require('express-fileupload');
const express = require('express')
const app = express();
const port = 8000;

const diagDir = 'diags'
app.use(fileUpload());
app.use(express.static(diagDir))

app.post('/upload', (req, res) => {
    if (!req.files || Object.keys(req.files).length === 0) {
        return res.status(400).send('No files uploaded.');
    }
    let diag = req.files.diag;
    if (diag.name.endsWith(".tgz")) {
        diag.mv(`${diagDir}/${diag.name}`, function (err) {
            if (err) {
                return res.status(500).send(err);
            }
        });
    } else {
        return res.status(403).send('Only .tgz files supported')
    }
    res.send(`File ${diag.name} uploaded`);
    console.log('File Uploaded:', diag.name)
})

app.get('/download/:id', (req, res) => {
    res.sendFile(req.params.id, {root: diagDir}, function (err) {
        if (err) {
            res.status(err.status).end();
        } else {
            console.log('File Downloaded:', req.params.id)
        }
    })
})

app.get('/', (req, res) => {
    res.send('Diag Service')
});

app.listen(port, () => {
    console.log(`App is listening on port ${port}!`)
});
