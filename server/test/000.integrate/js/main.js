var Graph = function(name, data) {
	this.name = name;
	this.width = $('#' + this.name).width();
	this.height = $('#' + this.name).height();

	this.x = d3.time.scale()
        .range([0, this.width]);
	
	this.y = d3.scale.linear()
        .range([this.height, 0]);
	
	this.xAxis = d3.svg.axis()
        .scale(this.x)
        .orient('top')
		.innerTickSize(0)
		.outerTickSize(0)
		.tickPadding(4);
	
	this.yAxis = d3.svg.axis()
        .scale(this.y)
        .orient('right')
		.innerTickSize(0)
		.outerTickSize(0)
		.tickPadding(4);
	
	this.line = d3.svg.line()
        .x(function(d) { return this.x(d.date); }.bind(this))
        .y(function(d) { return this.y(d[this.name]); }.bind(this));

	this.svg = d3.select("#" + this.name)
        .attr("width", this.width)
        .attr("height", this.height)
        .append("g")

	this.svg.selectAll('*')
		.remove();

    // set domain as data range
    this.x.domain(d3.extent(data, function(d) { return d.date; }));
    this.y.domain(d3.extent(data, function(d) { return d[this.name]; }.bind(this)));

    // show x axis
    this.svg.append("g")
        .attr("transform", "translate(0," + this.height + ")")
        .call(this.xAxis);

    // show y axis
    this.svg.append("g")
        .call(this.yAxis)

    // show line graph
    this.svg.append("path")
        .datum(data)
		.attr("stroke", "blue")
		.attr("fill", "none")
        .attr("d", this.line);
};

var Apl = function() {
	$('#date_select').bind('change', function() {
		console.log('change hoge');
		this.showGraph($('#date_select option:selected').val());

	}.bind(this));

	this.showGraph();

	var d = new Date();
	var date = d.getFullYear() +
		('0' + (d.getMonth() + 1)).slice(-2) +
		('0' + d.getDate()).slice(-2)
	$("#date_select").val(date);
	$("#date_select").change();
};

Apl.prototype.showGraph = function(date) {
	// date: yyyymmdd format
	d3.csv('./out.csv', function(error, data) {
		this.parseDate = d3.time.format("%Y%m%d_%H%M").parse;

		// format data
		data.forEach(function(d) {
			d.date = this.parseDate(d.date);
			d.humidity = +d.humidity;
			d.celsius = +d.celsius;
			d.illumination = +d.illumination;
			d.moisture = +d.moisture;
		}.bind(this));

		graph0 = new Graph('humidity', data);
		graph1 = new Graph('celsius', data);
		graph2 = new Graph('moisture', data);
		graph3 = new Graph('illumination', data);
	}.bind(this));
};

$(function() {
	var apl = new Apl();
//	apl.showGraph();
});
