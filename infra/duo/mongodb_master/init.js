var cfg = { _id: 'rs0',
    members: [
        { _id: 0, host: '#AUTO_REPLACE_SERVER_1:27001', "priority": 5},
        { _id: 1, host: '#AUTO_REPLACE_SERVER_2:27001', "priority": 2},
        { _id: 2, host: '#AUTO_REPLACE_SERVER_1:27002', "priority" : 0, "arbiterOnly" : true}
    ]
};

var error = rs.initiate(cfg);
printjson(error);
