@squares = []
@logoLetters = []

@LOGO_STRING = "FUNCTIONALIMPERATIVE"

class Canvas
  constructor: (args) ->
    @elem       = args.elem
    @pixelRatio = @getPixelRatio()
    @orient args.bodyWidth, args.bodyHeight

  getPixelRatio: ->
    testCtx = @elem[0].getContext('2d')
    dpr = window.devicePixelRatio or 1
    bspr = testCtx.webkitBackingStorePixelRatio or testCtx.mozBackingStorePixelRatio or testCtx.msBackingStorePixelRatio or testCtx.oBackingStorePixelRatio or testCtx.backingStorePixelRatio or 1
    dpr / bspr

  orient: (bodyWidth, bodyHeight) ->
    @width  = bodyWidth
    @height = bodyHeight
    @elem.attr 'width', (@width * @pixelRatio) 
    @elem.attr 'height', (@height * @pixelRatio) 

class Context
  constructor: (canvas) ->
    @width      = canvas.width
    @height     = canvas.height
    @pixelRatio = canvas.pixelRatio
    @ctx        = @getCtx canvas.elem[0]

  getCtx: (canvasElem) ->
    ctx = canvasElem.getContext "2d"
    ctx.setTransform @pixelRatio, 0, 0, @pixelRatio, 0, 0
    ctx.globalCompositeOperation = 'multiply'
    ctx

  clear: ->
    @ctx.setTransform @pixelRatio, 0, 0, @pixelRatio, 0, 0
    @ctx.clearRect 0, 0, @width, @height

class LogoLetter
  spriteSideLength: 120
  spritePadding: 4
  xOverlap: 5
  yOverlap: 12

  constructor: (args) ->
    @id            = args.id
    @ctx           = args.context.ctx
    @text          = args.text
    @anchorLeft    = args.anchor.left
    @anchorTop     = args.anchor.top
    @logoImgObject = args.logoImgObject
    @pixelRatio    = args.context.pixelRatio
    @sideLength    = @spriteSideLength / 2

    @setWord()
    @setColor()
    @resetPosition()
    @draw()

    logoLetters.push this
    this
    
  setWord: ->
    @word = if @id < 10 then 1 else 2

  setColor: ->
    colorString = if @word is 1 then "yellow" else "blue"
    @color = BASE_COLORS[colorString]

  resetPosition: ->
    mult = if @word is 1 then @id else @id - 10
    leftOffset = (mult * @sideLength) - (mult * @xOverlap)
    @left = @anchorLeft + leftOffset

    topOffset = if @word is 1 then 0 else @sideLength - @yOverlap
    @top = @anchorTop + topOffset

  draw: ->
    ySpriteOffset = @id * (@spriteSideLength + @spritePadding)
    @ctx.drawImage @logoImgObject, 0, ySpriteOffset, @spriteSideLength, @spriteSideLength, @left, @top, @sideLength, @sideLength

class Square
  fillHeight: 0
  fillSpeed: 8

  constructor: (args) ->
    @id         = args.id
    @ctx        = args.context.ctx
    @elem       = args.elem
    @color      = BASE_COLORS[(@elem.data('color'))]
    @type       = @elem.data('type')
    @state      = 'static'
    @orient()
    squares.push this
    this

  orient: ->
    @sideLength = @elem.outerHeight()
    @top        = @elem.offset().top
    @left       = @elem.offset().left

  draw: ->
    if @type is 'outlined'
      if @state is 'static'
        @fillHeight = 0
        @ctx.lineWidth = "1"
        @ctx.strokeStyle = @color
        @ctx.strokeRect @left, @top, @sideLength, @sideLength 
      if @state is 'hover'
        # draw border
        @ctx.lineWidth = "1"
        @ctx.strokeStyle = @color
        @ctx.strokeRect @left, @top, @sideLength, (@sideLength + @newFillHeight())
        # draw filled box
        @ctx.fillStyle = @color
        @ctx.fillRect @left, (@top + @sideLength), @sideLength, @newFillHeight()

  newFillHeight: ->
    if @fillHeight > -@sideLength
      @fillHeight -= @fillSpeed
    else
      @fillHeight = -@sideLength

animate = (args) ->
  context = args.context
  context.clear()
  for square in squares
    square.draw()
  for logoLetter in logoLetters
    logoLetter.draw()
  # continue animation
  requestAnimationFrame ->
    animate(context: context)

findById = (elem) ->
  id = elem.data('id')
  square = _.findWhere squares, id: id

animationId = undefined

$ -> 
  ##### create Canvas object
  args =
    elem: $('canvas')
    bodyWidth: $('body').width()
    bodyHeight: $('body').height()
  canvas = new Canvas(args)
  context = new Context(canvas)

  ##### create logo
  logoPosition = $('#logo').offset()
  logoSrc = $('#logo').data('imgSrc')

  logoImgObject = new Image()
  logoImgObject.src = logoSrc

  # wait for image to load
  logoImgObject.onload = ->
    # loop through letters
    for index in [0..(LOGO_STRING.length-1)]
      args =
        text: LOGO_STRING.charAt(index)
        anchor: logoPosition
        logoImgObject: logoImgObject
        context: context
        id: index
      logoLetter = new LogoLetter(args)

  ##### find and create Square objects
  $('.square').each (index) ->
    args =
      elem: $(this)
      context: context
      id: index
    square = new Square(args)
    $(this).data 'id', index
    square.draw()

  ##### handle events
  $('.square').mouseenter ->
    square = findById $(this)
    square.state = 'hover'
    # start animating
    animationId = requestAnimationFrame ->
      animate(context: context)

  $('.square').mouseleave ->
    square = findById $(this)
    square.state = 'static'
    # stop animating
    cancelAnimationFrame(animationId)

  $(window).resize ->
    canvas.orient $('body').width(), $('body').height()
    context.getCtx()
    for square in squares
      square.orient()     