class Lesson1
	getShader: (id) ->
		element = document.getElementById(id)
		if (!element)
			return null

		shaderScript = ""
		text = element.firstChild
		while (text)
			if (text.nodeType == 3)
				shaderScript += text.textContent
			text = text.nextSibling

		shader
		if (element.type == "x-shader/x-fragment")
			shader = @gl.createShader(@gl.FRAGMENT_SHADER)
		else if (element.type == "x-shader/x-vertex")
			shader = @gl.createShader(@gl.VERTEX_SHADER)
		else
			return null

		@gl.shaderSource(shader, shaderScript)
		@gl.compileShader(shader)

		if (!@gl.getShaderParameter(shader, @gl.COMPILE_STATUS))
			alert(@gl.getShaderInfoLog(shader))
			return null
		
		return shader
	
	initGL: (canvas) ->
		@gl = canvas.getContext("experimental-webgl")
		@gl.viewportWidth = canvas.width
		@gl.viewportHeight = canvas.height

	initShaders: () ->
		@pMatrix = mat4.create()
		@mvMatrix = mat4.create()
		@mvMatrixStack = []

		@shaderProgram = @gl.createProgram()

		fragmentShader = this.getShader("shader-fs")
		vertexShader = this.getShader("shader-vs")

		@gl.attachShader(@shaderProgram, vertexShader)
		@gl.attachShader(@shaderProgram, fragmentShader)
		@gl.linkProgram(@shaderProgram)

		@gl.useProgram(@shaderProgram)

		@shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexPosition")
		@gl.enableVertexAttribArray(@shaderProgram.vertexPositionAttribute)

		@shaderProgram.colorPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexColor")
		@gl.enableVertexAttribArray(@shaderProgram.vertexColorAttribute)

		@shaderProgram.pMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uPMatrix")
		@shaderProgram.mvMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uMVMatrix")
	
	createBuffer: (itemSize, items) ->
		buffer = @gl.createBuffer()

		@gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(items), @gl.STATIC_DRAW)
		
		buffer.itemSize = itemSize
		buffer.numItems = items.length / itemSize
		
		return buffer

	initBuffers: () ->
		@triangleBuffer = this.createBuffer(3,
			[
				0.0, 1.0, 0.0,
				-1.0, -1.0, 0.0,
				1.0, -1.0, 0.0
			]
		)

		@triangleColorBuffer = this.createBuffer(4,
			[
				1.0, 0.0, 0.0, 1.0,
				0.0, 1.0, 0.0, 1.0,
				0.0, 0.0, 1.0, 1.0
			]
		)

		@squareBuffer = this.createBuffer(3,
			[
				1.0, 1.0, 0.0,
				-1.0, 1.0, 0.0,
				1.0, -1.0, 0.0,
				-1.0, -1.0, 0.0
			]
		)

		@squareColorBuffer = this.createBuffer(4,
			[
				0.5, 0.5, 1.0, 1.0,
				0.5, 0.5, 1.0, 1.0,
				0.5, 0.5, 1.0, 1.0,
				0.5, 0.5, 1.0, 1.0
			]
		)

	initAnimation: () ->
		@triangleRotation = 0
		@squareRotation = 0

		@lastTime = 0
	
	mvPushMatrix: () ->
		copy = mat4.create()
		mat4.set(@mvMatrix, copy)
		@mvMatrixStack.push(copy)
	
	mvPopMatrix: () ->
		if(@mvMatrixStack.length == 0)
			throw "Invalid popMatrix!"

		@mvMatrix = @mvMatrixStack.pop()
	
	degToRad: (degrees) ->
		return degrees * Math.PI / 180

	setMatrixUniforms: () ->
		@gl.uniformMatrix4fv(@shaderProgram.pMatrixUniform, false, @pMatrix)
		@gl.uniformMatrix4fv(@shaderProgram.mvMatrixUniform, false, @mvMatrix)
	
	drawTriangleStrip: (verticeBuffer, colorBuffer) ->
		@gl.bindBuffer(@gl.ARRAY_BUFFER, verticeBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, verticeBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		@gl.bindBuffer(@gl.ARRAY_BUFFER, colorBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexColorAttribute, colorBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		this.setMatrixUniforms()
		@gl.drawArrays(@gl.TRIANGLE_STRIP, 0, verticeBuffer.numItems)

	drawScene: () ->
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
		mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix)
		mat4.identity(@mvMatrix)

		mat4.translate(@mvMatrix, [-1.5, 0.0, -7.0])
		this.mvPushMatrix()
		mat4.rotate(@mvMatrix, this.degToRad(@triangleRotation), [0, 1, 0])
		this.drawTriangleStrip(@triangleBuffer, @triangleColorBuffer)
		this.mvPopMatrix()

		this.mvPushMatrix()
		mat4.rotate(@mvMatrix, this.degToRad(@squareRotation), [1, 0, 0])
		mat4.translate(@mvMatrix, [3.0, 0.0, 0.0])
		this.drawTriangleStrip(@squareBuffer, @squareColorBuffer)
		this.mvPopMatrix()
	
	animate: () ->
		timeNow = new Date().getTime()

		if(@lastTime != 0)
			elapsed = timeNow - @lastTime
			@triangleRotation += (90.0 * elapsed) / 1000.0
			@squareRotation += (75.0 * elapsed) / 1000.0

		@lastTime = timeNow

	tick: () ->
		requestAnimFrame () =>
			this.tick()

		this.drawScene()
		this.animate()

	webGLStart: () ->
		canvas = document.getElementById("canvas1")
		this.initGL(canvas)
		this.initShaders()
		this.initBuffers()
		this.initAnimation()

		@gl.clearColor(0.0, 0.0, 0.0, 1.0)
		@gl.enable(@gl.DEPTH_TEST)

		this.tick()

lesson = new Lesson1
lesson.webGLStart()
