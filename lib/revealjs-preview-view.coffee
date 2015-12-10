path = require 'path'
_ = require 'underscore-plus'
{$, $$$, View} = require 'atom-space-pen-views'
_Markdown = require 'reveal.js/plugin/markdown/markdown'
Reveal = require './reveal.js'
{CompositeDisposable} = require 'atom'

module.exports =
class ReealjsPreviewView extends View
  @content: ->
    @div class: 'revealjs-preview native-key-bindings', tabindex: -1

  constructor: (@editorId) ->
    super
    @subscriptions = new CompositeDisposable
    if @editorId?
      @resolveEditor(@editorId)

  destroy: ->
    @subscriptions.dispose()

  resolveEditor: (editorId) ->
    resolve = =>
      if @editor = @editorForId(editorId)
        @handleEvents()

    if atom.workspace?
      resolve()
    else
      atom.packages.once 'activated', =>
        resolve()
        @renderSlide()

  editorForId: (editorId) ->
    _.find atom.workspace.getTextEditors(), (editor) ->
      editor.id?.toString() is editorId

  handleEvents: ->
    changeHandler = =>
      @renderSlide()
      pane = atom.workspace.paneForURI(@getUri())
      if pane? and pane isnt atom.workspace.getActivePane()
        pane.activateItem(this)

    @subscriptions.add @editor.onDidSave(changeHandler)
    #@subscriptions.add @editor.onDidChange(changeHandler)

  getRevealjsPrevewDirPath: ->
    filtered = atom.packages.getAvailablePackagePaths().filter (x) -> x.indexOf('revealjs-preview') > -1
    _.first(filtered)

  renderSlide: ->
    @showLoading()

    package_dir_path = @getRevealjsPrevewDirPath()

    text = @resolvePath(@editor.getText())
    css = """
    <link rel="stylesheet" href="#{package_dir_path}/css/reveal.css" type="text/css" />
    <link rel="stylesheet" href="#{package_dir_path}/css/theme/black.css" id="theme" />
    """
    @html """
<div class="reveal">
  <div class="slides">
    #{_Markdown.slidify(text)}
  </div>
</div>
#{@resolvePath(css)}
"""
    _Markdown.processSlides()
    _Markdown.convertSlides()

    Reveal.initialize
      keyboard: true
      center: false
      transition: 'slide'
      backgroundTransition: 'slide'

    Reveal.slide(@checkSlidePosition())

  checkSlidePosition: ->
    point = @editor.getCursorBufferPosition()
    forwardText = @editor.getTextInBufferRange([[0,0], point])
    if result = forwardText.match(/^\r?\n---\r?\n$/g)
      result.length
    else
      0

  resolvePath: (s) ->
    s.replace(/\.\//g, path.dirname(@editor.getPath())+'/')

  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} Preview"
    else
      "RevealJS Preview"

  getUri: ->
    "revealjs-preview://editor/#{@editorId}"

  showLoading: ->
    @html $$$ ->
      @div class: 'markdown-spinner', 'Loading Slide\u2026'
