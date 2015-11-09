url = require 'url'
fs = require 'fs-plus'

RevealjsPreviewView = require './revealjs-preview-view'

module.exports =

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'revealjs-preview:toggle': => @toggle()

    atom.workspace.addOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse(uriToOpen)
      pathname = decodeURI(pathname) if pathname
      return unless protocol is 'revealjs-preview:'
      return unless host is 'editor'
      new RevealjsPreviewView(pathname.substring(1))


  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    uri = "revealjs-preview://editor/#{editor.id}"

    if previewPane = atom.workspace.paneForURI(uri)
      previewPane.destroyItem(previewPane.itemForURI(uri))
    else
      previousActivePane = atom.workspace.getActivePane()
      atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (view) ->
        if view instanceof RevealjsPreviewView
          view.renderSlide()
          previousActivePane.activate()
