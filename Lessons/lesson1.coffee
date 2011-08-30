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
		@shaderProgram = @gl.createProgram()

		fragmentShader = this.getShader("shader-fs")
		vertexShader = this.getShader("shader-vs")

		@gl.attachShader(@shaderProgram, vertexShader)
		@gl.attachShader(@shaderProgram, fragmentShader)
		@gl.linkProgram(@shaderProgram)

		@gl.useProgram(@shaderProgram)

		@shaderProgram.vertiexPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexPosition")
		@gl.enableVertexAttribArray(@shaderProgram.vertexPositionAttribute)

		@shaderProgram.pMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uPMatrix")
		@shaderProgram.mvMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uMVMatrix")
	
	createBuffer: (itemSize, vertices) ->
		console.log vertices
		buffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW)
		buffer.itemSize = itemSize
		buffer.numItems = vertices.length / itemSize
		return buffer

	initBuffers: () ->
		@triangleBuffer = this.createBuffer(3,
			[
				0.0, 1.0, 0.0,
				-1.0, -1.0, 0.0,
				1.0, -1.0, 0.0
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

	setMatrixUniforms: () ->
		@gl.uniformMatrix4fv(@shaderProgram.pMatrixUniform, false, @pMatrix)
		@gl.uniformMatrix4fv(@shaderProgram.mvMatrixUniform, false, @mvMatrix)

	drawScene: () ->
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
		mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix)
		mat4.identity(@mvMatrix)

		mat4.translate(@mvMatrix, [-1.5, 0.0, -7.0])
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @triangleBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, @triangleBuffer.itemSize, @gl.FLOAT, false, 0, 0)
		this.setMatrixUniforms()
		@gl.drawArrays(@gl.TRIANGLES, 0, @triangleBuffer.numItems)

		mat4.translate(@mvMatrix, [3.0, 0.0, 0.0])
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @squareBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, @squareBuffer.itemSize, @gl.FLOAT, false, 0, 0)
		this.setMatrixUniforms()
		@gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @squareBuffer.numItems)

	webGLStart: () ->
		canvas = document.getElementById("canvas1")
		this.initGL(canvas)
		this.initShaders()
		this.initBuffers()

		@gl.clearColor(0.0, 0.0, 0.0, 1.0)
		@gl.enable(@gl.DEPTH_TEST)

		this.drawScene()

lesson = new Lesson1
lesson.webGLStart()
