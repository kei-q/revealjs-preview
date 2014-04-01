url = require 'url'
fs = require 'fs-plus'

RevealjsPreviewView = require './revealjs-preview-view'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'revealjs-preview:toggle', =>
      @toggle()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse(uriToOpen)
      pathname = decodeURI(pathname) if pathname
      return unless protocol is 'revealjs-preview:'
      return unless host is 'editor'
      new RevealjsPreviewView(pathname.substring(1))

  toggle: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    uri = "revealjs-preview://editor/#{editor.id}"

    if previewPane = atom.workspace.paneForUri(uri)
      previewPane.destroyItem(previewPane.itemForUri(uri))
    else
      previousActivePane = atom.workspace.getActivePane()
      atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (view) ->
        if view instanceof RevealjsPreviewView
          view.renderSlide()
          previousActivePane.activate()
