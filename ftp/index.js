const {connect} = require("net");


const client = connect(21, process.argv[2]);

let interval = undefined;

const write = (message) => {
	console.log(`>> ${message}`);
	client.write(`${message}\n`);
};

client.on("data", async (d) => {
	const message = d.toString();
	if (message.startsWith("220")) {
		console.log("Connected");
		
		const interval = setInterval(() => {
			console.log("Logging in...");
			// https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/ToRussianPeople.md
			write(`USER github.com/vshymanskyy/StandWithUkraine/blob/main/docs/ToRussianPeople.md`);
			write(`PASS Слава Украине`);
		}, 1000);
	}

	console.log(`<< ${message}`);
});
client.on("error", (e) => console.error(`ERR ${e.message}`));
client.on("close", () => {
	console.log("Disconnected");
	if (interval) {
		clearInterval(interval);
		interval = undefined;
	}
});
