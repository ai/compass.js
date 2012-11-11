fs     = require('fs-extra')
exec   = require('child_process').exec
http   = require('http')
path   = require('path')
glob   = require('glob')
coffee = require('coffee-script')
uglify = require('uglify-js')

mocha =

  template: """
            <html>
            <head>
              <meta charset="UTF-8">
              <title>Compass.js Tests</title>
              <style>#style#</style>
              <script>#script#</script>
              <script src="/lib/compass.js"></script>
              <script>#tests#</script>
              <style>
                body {
                  padding: 0;
                }
                #integration {
                  position: absolute;
                  top: 1.45em;
                  margin-left: 120px;
                  font-weight: 200;
                  font-size: 0.7em;
                }
              </style>
            <body>
              <a href="/integration" id="integration" target="_blank">
                see also integration test →
              </a>
              <div id="mocha"></div>
              <script>
                document.body.onload = function() {
                  mocha.setup({ ui: 'bdd', ignoreLeaks: true });
                  mocha.run();
                };
              </script>
            </body>
            </html>
            """

  html: ->
    @render @template,
      style:  @cdata(@style())
      script: @cdata(@script())
      tests:  @cdata(@tests())

  render: (template, params) ->
    html = template
    for name, value of params
      html = html.replace("##{name}#", value.replace(/\$/g, '$$$$'))
    html

  cdata: (text) ->
    "/*<![CDATA[*/\n" +
    text + "\n" +
    "/*]]>*/"

  style: ->
    fs.readFileSync('node_modules/mocha/mocha.css')

  script: ->
    @testLibs() +
    "chai.should();\n" +
    "mocha.setup('bdd');\n"

  testLibs: ->
    fs.readFileSync('node_modules/mocha/mocha.js') +
    fs.readFileSync('node_modules/chai/chai.js') +
    fs.readFileSync('node_modules/sinon/lib/sinon.js') +
    fs.readFileSync('node_modules/sinon/lib/sinon/spy.js') +
    fs.readFileSync('node_modules/sinon/lib/sinon/stub.js') +
    fs.readFileSync('node_modules/sinon/lib/sinon/match.js') +
    fs.readFileSync('node_modules/sinon/lib/sinon/util/fake_timers.js') +
    fs.readFileSync('node_modules/sinon-chai/lib/sinon-chai.js')

  lib: ->
    fs.readFileSync('lib/compass.js')

  tests: ->
    files  = fs.readdirSync('test/').
      filter( (i) -> i.match /\.coffee$/ ).map( (i) -> "test/#{i}" )
    src = files.reduce ( (all, i) -> all + fs.readFileSync(i) ), ''
    coffee.compile(src)

task 'test', 'Run specs server', ->
  server = http.createServer (req, res) ->
    if req.url == '/'
      res.writeHead 200, { 'Content-Type': 'text/html' }
      res.write mocha.html()
    else if req.url == '/lib/compass.js'
      res.writeHead 200, { 'Content-Type': 'text/javascript' }
      res.write mocha.lib()
    else if req.url == '/integration'
      res.writeHead 200, { 'Content-Type': 'text/html' }
      res.write fs.readFileSync('test/integration.html')
    else
      res.writeHead 404, { 'Content-Type': 'text/plain' }
      res.write 'Not Found'
    res.end()
  server.listen 8000
  console.log('Open http://localhost:8000/')

task 'clean', 'Remove all generated files', ->
  fs.removeSync('build/') if path.existsSync('build/')
  fs.removeSync('pkg/')   if path.existsSync('pkg/')

task 'min', 'Create minimized version of library', ->
  fs.mkdirsSync('pkg/') unless path.existsSync('pkg/')
  version = JSON.parse(fs.readFileSync('package.json')).version
  source  = fs.readFileSync('lib/compass.js').toString()

  ast = uglify.parser.parse(source)
  ast = uglify.uglify.ast_mangle(ast)
  ast = uglify.uglify.ast_squeeze(ast)
  min = uglify.uglify.gen_code(ast)

  fs.writeFileSync("pkg/compass-#{version}.min.js", min)

task 'gem', 'Build RubyGem package', ->
  fs.removeSync('build/') if path.existsSync('build/')
  fs.mkdirsSync('build/lib/assets/javascripts/')

  copy = require('fs-extra/lib/copy').copyFileSync
  copy('gem/compassjs.gemspec', 'build/compassjs.gemspec')
  copy('gem/compassjs.rb',      'build/lib/compassjs.rb')
  copy('lib/compass.js',        'build/lib/assets/javascripts/compass.js')
  copy('README.md',             'build/README.md')
  copy('ChangeLog',             'build/ChangeLog')
  copy('LICENSE',               'build/LICENSE')

  exec 'cd build/; gem build compassjs.gemspec', (error, message) ->
    if error
      process.stderr.write(error.message)
      process.exit(1)
    else
      fs.mkdirsSync('pkg/') unless path.existsSync('pkg/')
      gem = glob.sync('build/*.gem')[0]
      copy(gem, gem.replace(/^build\//, 'pkg/'))
      fs.removeSync('build/')
