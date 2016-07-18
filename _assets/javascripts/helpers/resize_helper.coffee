@ResizeHelper =
  resizeSquares: ($squares) ->
    $squares.css 'width', '100%'
    widths = $squares.map ->
      $square = $(this)
      Math.round($square.outerWidth())    
    $squares.each (i) ->
      $square = $(this)
      $square.css 'width', widths[i]
      $square.css 'height', widths[i]
      
  resizeScenes: ($scenes) ->
    $scenes.each((index, scene) ->
      $scene = $(scene)
      $scene.css('height', "")
      # Set size of each scene to window height
      $scene.css('height', Math.max(window.innerHeight, $scene.innerHeight()))
    )

  addFooterToggleListener: () ->
    $(window).resize(@toggleFooter)
        
  toggleFooter: () ->
    $body = $('#body')
    $footer = $('footer')
    if (window.innerWidth < window.SCREEN_WIDTH_UPPER_LIMITS.medium)
      # Show the footer
      $body.removeClass('footer-hidden')
      $footer.removeClass('hidden')
    else
      # Hide the footer
      $body.addClass('footer-hidden')
      $footer.addClass('hidden')
  
  resizeNav: ($menuLink) ->
    $navMenu = $('.nav-menu')
    if $menuLink.length > 0 && window.innerWidth > window.SCREEN_WIDTH_UPPER_LIMITS.medium
      $subMenuLinks = $menuLink.siblings().children()
      newNavWidth = $subMenuLinks.length * $subMenuLinks.outerWidth() + 75 # The extra 75 is from the size of the selected nav-menu-item when the sub-menu is open
      console.log(newNavWidth)
      $navMenu.css('width', Math.min(newNavWidth, window.innerWidth))
    else if window.innerWidth <= window.SCREEN_WIDTH_UPPER_LIMITS.medium
      $navMenu.css('width', '')

  handleResize: (args) ->
    
    @resizeSquares($('.square'))
    @resizeSquares($('.square-no-canvas'))
    @resizeSquares($('.square-no-canvas-no-fill'))
    @resizeNav($('.nav-menu-item.active > .nav-menu-item-link'))
    
    @resizeScenes($('.cubes-scene'))
    
    for canvas in window.canvases
      canvas.orient()
      canvas.context.clear 0, 0, canvas.width, canvas.height
      canvas.context.setMultiply()

      for square in canvas.squares
        square.orient()

      canvas.adjustSquarePositions()
      
      for square in canvas.squares
        square.draw()

  windowOrientation: undefined