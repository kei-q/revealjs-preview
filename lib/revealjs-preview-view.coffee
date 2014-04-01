path = require 'path'
_ = require 'underscore-plus'
{$, $$$, View} = require 'atom'

_Markdown = require 'reveal.js/plugin/markdown/markdown'
Reveal = require './reveal.js'

module.exports =
class ReealjsPreviewView extends View
  @content: ->
    @div class: 'revealjs-preview native-key-bindings', tabindex: -1

  constructor: (@editorId) ->
    super
    if @editorId?
      @resolveEditor(@editorId)

  destroy: ->
    @unsubscribe()

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
    _.find atom.workspace.getEditors(), (editor) ->
      editor.id?.toString() is editorId

  handleEvents: ->
    changeHandler = =>
      @renderSlide()
      pane = atom.workspace.paneForUri(@getUri())
      if pane? and pane isnt atom.workspace.getActivePane()
        pane.activateItem(this)

    @subscribe(@editor.getBuffer(), 'saved', changeHandler)

  renderSlide: ->
    @showLoading()

    text = @resolvePath(@editor.getText())
    css = """
    <link rel="stylesheet" href="./default.css" type="text/css" />
    """
    @html """
<div class="reveal"><div class="slides">
#{_Markdown.slidify(text)}
</div></div>
#{@resolvePath(css)}
"""

    _Markdown.processSlides()
    _Markdown.convertSlides()

    Reveal.initialize
      center: false
      transition: 'slide'
      backgroundTransition: 'slide'

    Reveal.slide(@checkSlidePosition())

  checkSlidePosition: ->
    point = @editor.getCursorBufferPosition()
    forwardText = @editor.getTextInBufferRange([[0,0], point])
    if result = forwardText.match(/\n---\n/g)
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
