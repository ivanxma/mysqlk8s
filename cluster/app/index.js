const http = require('http');
const mysqlx = require('@mysql/xdevapi');
const SERVICE_NAMESPACE = process.env.MYSQL_SERVICE_NAMESPACE
? process.env.MYSQL_SERVICE_NAMESPACE
: 'default';
const MYSQL_CONFIG = {
password: process.env.MYSQL_PASS,
user: process.env.MYSQL_USER,
host: `_${process.env.MYSQL_SERVICE_PORT}._tcp.${
process.env.MYSQL_SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local`, resolveSrv: true,
};
const queries = [
'show full processlist',
'select * from performance_schema.replication_group_member_stats', 'select * from mysql.user', 'select @@hostname'
];
const handleRequest = async function(request, response) {
const url = new URL(request.url, `http://${request.headers.host}`); console.log('Received request for URL: ' + request.url); response.setHeader('Content-Type', 'text/html'); response.writeHead(200);
response.write('<style>td { font-family: monospace; }</style>'); response.write(`<form action="/" method="get"><textarea name="sql">${
url.searchParams.get('sql')}</textarea><input type="Submit"></form><ul>`);
response.write( queries
.map(q =>
`<li><a href="/?sql=${encodeURIComponent(q)}">${q}</a></li>`)
.join('')); response.write('</ul><hr>');
if (!url.searchParams || !url.searchParams.has('sql')) { response.end('No query');
return;
}
let session; try {
session = await mysqlx.getSession(MYSQL_CONFIG); // URL); response.write('<table border="1">');
let meta_count = 0;
await session.sql(url.searchParams.get('sql'))
.execute(row => response.write('<tr><td>' + row.join('</td><td>') + '</td></tr>'),
meta => !meta_count++ &&
response.write( '<tr><th>' +
meta.map(c => c.getColumnLabel()).join('</th><th>') +
'</th></tr>')); response.write('</table>');
} catch (e) {
response.write("<b>ERROR:</b> " + e.toString());
} finally {
session && session.close();
}
response.end(); };
const www = http.createServer(handleRequest); www.listen(8181);
console.log('Waiting for requests ...');
