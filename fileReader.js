#!/usr/local/bin/node
var fs = require("fs");
var path = require("path");
var path = require("path");
var LineStream = require('byline').LineStream;


function readFile(file) {
  var lineStream = new LineStream();
  lineStream.on('data', function(line) {
    var object = JSON.parse(line);
    console.log(JSON.stringify(object, null, 1));
  });

  var fileStream = fs.createReadStream(file);
  fileStream.pipe(lineStream);
}

readFile(process.argv[2]);

