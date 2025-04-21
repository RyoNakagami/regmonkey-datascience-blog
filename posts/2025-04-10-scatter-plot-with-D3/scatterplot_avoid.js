// Dimensions of chart.
let margin = { top: 20, right: 20, bottom: 50, left: 20 },
  // width = parseInt(d3.select('#chart').style('width'), 10) - margin.left - margin.right,
  width = 350 - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;


// Start SVG
let svg = d3
  .select("#chart")
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Scales: x and y
let x = d3
  .scaleLinear()
  // .domain([0, 6])
  .domain([3, 6])
  .range([0, width]);
let y = d3
  .scaleLinear()
  // .domain([0, 6])
  .domain([2, 6])
  .range([height, 0]);

let r = 3;

// Point color
let ptcolor = "#808080";

// x-axis
let xAxis = d3
  .axisBottom(x)
  // .ticks(7)
  .ticks(4)
  .tickSize(-height - 8)
  .tickPadding(5);
let xAxisEl = svg
  .append("g")
  .attr("class", "x axis bottom")
  .attr("transform", "translate(0," + (height + 8) + ")");
xAxisEl
  .append("text")
  .attr("class", "axistitle")
  .attr("text-anchor", "start")
  .attr("x", 0)
  .attr("y", 0)
  .attr("dx", "-.25em")
  .attr("dy", "2.5em")
  .text("Meaningfulness Score Average");
xAxisEl.call(xAxis);

// y-axis
let yAxis = d3
  .axisLeft(y)
  // .ticks(7)
  .ticks(5)
  .tickSize(-width - 8)
  .tickPadding(5);
var yAxisEl = svg
  .append("g")
  .attr("class", "y axis left")
  .attr("transform", "translate(" + -8 + ",0)");
yAxisEl
  .append("text")
  .attr("class", "axistitle")
  .attr("x", 0)
  .attr("y", 0)
  .attr("dx", "4px")
  .attr("dy", "-2em")
  .style("text-anchor", "end")
  .attr("transform", "rotate(-90)")
  .text("Happiness Score Average");
yAxisEl.call(yAxis);

let activities;
let circle, labeltext;

// Load data
const activitiesData = Promise.all([d3.tsv("./act_means.tsv", d3.autoType)]);
activitiesData.then(function (data) {
  activities = data[0];
  // console.log(activities);

  // Initialize chart now that data is loaded.
  initChart();
});

function initChart() {
  // Circle for each node.
  circle = svg
    .append("g")
    .selectAll("circle")
    .data(activities)
    .join("circle")
    .attr("id", (d) => "circle" + d.activity)
    .attr("cx", (d) => x(d.meaning_mean))
    .attr("cy", (d) => y(d.schappy_mean))
    .attr("fill", ptcolor)
    .attr("r", 3);

  //   setInteraction();
}

function setInteraction() {
  // Create label
  labeltext = svg.append("text").attr("text-anchor", "middle");

  // Hover events
  circle
    .on("mouseover", function (e, d) {
      d3.selectAll(".current").classed("current", false);
      d3.select(this).classed("current", true);

      let curract = d3.select(this).datum();

      labeltext
        .text(curract.descrip)
        .attr("x", x(curract.meaning_mean))
        .attr("y", y(curract.schappy_mean) - r(curract.relwt) - 5);
    })
    .on("mouseout", function (d) {
      d3.select(this).classed("current", false);
      labeltext.text("");
    }); // @end mouseout
}
