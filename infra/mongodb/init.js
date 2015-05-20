var cfg = { _id: 'rs0',
    members: [
        { _id: 0, host: '127.0.0.1:27001', "priority": 5},
        { _id: 1, host: '127.0.0.1:27002', "priority": 2},
        { _id: 2, host: '127.0.0.1:27003', "priority" : 0, "arbiterOnly" : true}
    ]
};

var error = rs.initiate(cfg);
printjson(error);
