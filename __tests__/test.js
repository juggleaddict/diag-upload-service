import { index, upload, download } from '../index.js'

describe('Test Handlers', function () {
    
    test('responds to /', () => {
        const req = { };
        const res = { text: '', 
            send: function(input) { this.text = input }
        };
        index(req,res);
        expect(res.text).toEqual('Diag Service');
    });
});