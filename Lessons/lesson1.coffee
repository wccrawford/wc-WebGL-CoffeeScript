class Lesson1
	gl = null
	triangleBuffer = null
	squareBuffer = null

	pMatrix = mat4.create()
	mvMatrix = mat4.create()

	shaderProgram = null

	getShader: (gl, id) ->
		shaderScript = document.getElementById(id)
		if (!shaderScript)
			return null

		str = ""
		k = shaderScript.firstChild
		while (k)
			if (k.nodeType == 3)
				str += k.textContent
			k = k.nextSibling

		shader
		if (shaderScript.type == "x-shader/x-fragment")
			shader = gl.createShader(gl.FRAGMENT_SHADER)
		else if (shaderScript.type == "x-shader/x-vertex")
			shader = gl.createShader(gl.VERTEX_SHADER)
		else
			return null

		gl.shaderSource(shader, str)
		gl.compileShader(shader)

		if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
			alert(gl.getShaderInfoLog(shader))
			return null
		
		return shader

	initGL: (canvas) ->
		gl = canvas.getContext("experimental-webgl")
		gl.viewportWidth = canvas.width
		gl.viewportHeight = canvas.height

	initShaders: () ->
		shaderProgram = gl.createProgram()

		fragmentShader = this.getShader(gl, "shader-fs")
		vertexShader = this.getShader(gl, "shader-vs")

		gl.attachShader(shaderProgram, vertexShader)
		gl.attachShader(shaderProgram, fragmentShader)
		gl.linkProgram(shaderProgram)

		gl.useProgram(shaderProgram)

		shaderProgram.vertiexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition")
		gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute)

		shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix")
		shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix")

	initBuffers: () ->
		triangleBuffer = gl.createBuffer()
		gl.bindBuffer(gl.ARRAY_BUFFER, triangleBuffer)
		vertices = [
			0.0, 1.0, 0.0,
			-1.0, -1.0, 0.0,
			1.0, -1.0, 0.0
		]
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)
		triangleBuffer.itemSize = 3
		triangleBuffer.numItems = 3

		squareBuffer = gl.createBuffer()
		gl.bindBuffer(gl.ARRAY_BUFFER, squareBuffer)
		vertices2 = [
			1.0, 1.0, 0.0,
			-1.0, 1.0, 0.0,
			1.0, -1.0, 0.0,
			-1.0, -1.0, 0.0
		]
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices2), gl.STATIC_DRAW)
		squareBuffer.itemSize = 3
		squareBuffer.numItems = 4

	setMatrixUniforms: () ->
		gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix)
		gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix)

	drawScene: () ->
		gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix)
		mat4.identity(mvMatrix)

		mat4.translate(mvMatrix, [-1.5, 0.0, -7.0])
		gl.bindBuffer(gl.ARRAY_BUFFER, triangleBuffer)
		gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, triangleBuffer.itemSize, gl.FLOAT, false, 0, 0)
		this.setMatrixUniforms()
		gl.drawArrays(gl.TRIANGLES, 0, triangleBuffer.numItems)

		mat4.translate(mvMatrix, [3.0, 0.0, 0.0])
		gl.bindBuffer(gl.ARRAY_BUFFER, squareBuffer)
		gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, squareBuffer.itemSize, gl.FLOAT, false, 0, 0)
		this.setMatrixUniforms()
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, squareBuffer.numItems)

	webGLStart: () ->
		canvas = document.getElementById("canvas1")
		this.initGL(canvas)
		this.initShaders()
		this.initBuffers()

		gl.clearColor(0.0, 0.0, 0.0, 1.0)
		gl.enable(gl.DEPTH_TEST)

		this.drawScene()

lesson = new Lesson1
lesson.webGLStart()
