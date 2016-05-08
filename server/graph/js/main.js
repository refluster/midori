var Apl = function() {
    this.parseDate = d3.time.format("%Y%m%d_%H%M").parse;
	this.width = $('#humidity').width();
	this.height = $('#humidity').height();

	this.x = d3.time.scale()
        .range([0, this.width]);
	
	this.y = d3.scale.linear()
        .range([this.height, 0]);
	
	this.xAxis = d3.svg.axis()
        .scale(this.x)
        .orient('top')
		.ticks(d3.time.hour, 3)
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
        .y(function(d) { return this.y(d.humidity); }.bind(this));
	
	this.svg = d3.select("#humidity")
        .attr("width", this.width)
        .attr("height", this.height)
        .append("g")
};

Apl.prototype.showGraph = function(idx) {
    d3.csv("../log/20160508_30min.csv", function(error, data) {
        // format data
        data.forEach(function(d) {
            d.date = this.parseDate(d.date);
            d.humidity = +d.humidity;
        }.bind(this));

        // set domain as data range
        this.x.domain(d3.extent(data, function(d) { return d.date; }));
        this.y.domain(d3.extent(data, function(d) { return d.humidity; }));

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
    }.bind(this));
};

$(function() {
	var apl = new Apl();
	apl.showGraph();
});
