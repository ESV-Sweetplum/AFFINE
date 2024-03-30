const fs = require("fs");
const chalk = require("chalk");

const { createInterface } = require("readline");

const defaultSettings = fs
  .readFileSync("./plugin.lua", "utf-8")
  .split("-- END DEFAULT SETTINGS")[0]
  .replaceAll("\n\n", "\n")
  .split("\n")
  .filter((v) => v)
  .map((setting) => {
    return {
      key: setting.split(" = ")[0],
      label: setting
        .split(" = ")[0]
        .replaceAll("_", " ")
        .split(" ")
        .reduce(
          (str, arg) => `${str} ${arg.charAt(0)}${arg.toLowerCase().slice(1)}`,
          ""
        )
        .slice(1),
      value: setting
        .split(" = ")[1]
        .replaceAll(/( ){2,}/g, " ")
        .split(" --")[0]
        .replaceAll(/'/g, ""),
      dataType: setting.split("-- ")[1],
    };
  });

console.log(`
           ______ ______ _____ _   _ ______       _____ ______ _______ _______ _____ _   _  _____  _____ 
     /\\   |  ____|  ____|_   _| \\ | |  ____|     / ____|  ____|__   __|__   __|_   _| \\ | |/ ____|/ ____|
    /  \\  | |__  | |__    | | |  \\| | |__       | (___ | |__     | |     | |    | | |  \\| | |  __| (___  
   / /\\ \\ |  __| |  __|   | | | . \` |  __|       \\___ \\|  __|    | |     | |    | | | . \` | | |_ |\\___ \\ 
  / ____ \\| |    | |     _| |_| |\\  | |____      ____) | |____   | |     | |   _| |_| |\\  | |__| |____) |
 /_/    \\_\\_|    |_|    |_____|_| \\_|______|    |_____/|______|  |_|     |_|  |_____|_| \\_|\\_____|_____/                                                                                                   
`);

function printSettingsTable() {
  console.table(defaultSettings, ["label", "value", "dataType"]);
}

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

printSettingsTable();

function prompt() {
  rl.question(
    `${chalk.blue.bold(
      "Enter an index"
    )} to change the corresponding setting, ${chalk.green.bold(
      "SAVE"
    )} to save and exit, or ${chalk.red.bold("EXIT")} to exit without saving. `,
    (input) => {
      input = input.toLowerCase();
      if (input == "exit" || !input) {
        rl.close();
        process.exit();
      }
      if (input == "save") {
        let file = fs
          .readFileSync("./plugin.lua", "utf-8")
          .split("-- END DEFAULT SETTINGS")[1]
          .split("\n")
          .slice(1);

        file.unshift("-- END DEFAULT SETTINGS (DONT DELETE THIS LINE)");

        defaultSettings.reverse().forEach((setting) => {
          file.unshift(
            `${setting.key} = ${
              setting.dataType === "integer[any]" ? "'" : ""
            }${setting.value}${
              setting.dataType === "integer[any]" ? "'" : ""
            } -- ${setting.dataType}`
          );
        });

        fs.writeFileSync("./plugin.lua", file.join("\n"));

        rl.close();
        process.exit();
      }
      if (!Number.isInteger(parseInt(input)) || !defaultSettings[input]) {
        console.error(
          chalk.red.bold("\nThis isn't a valid input. Please try again.\n")
        );
      } else {
        console.log(
          `${chalk.green.bold(
            `You have selected: ${defaultSettings[input].key}.`
          )}\n${chalk.blue.bold(
            `Please input a value for this item. (type: ${defaultSettings[input].dataType})`
          )}`
        );
        selectValue(input);
      }

      prompt();
    }
  );
}

function selectValue(input) {
  rl.question("Value: ", (v) => {
    switch (defaultSettings[input].dataType) {
      case "string": {
        defaultSettings[input].value = v.replaceAll(/[A-z]/g, "");
        console.log(
          chalk.bold(
            `${chalk.blue(
              defaultSettings[input].key
            )} has been set to: ${chalk.yellow(defaultSettings[input].value)}.`
          )
        );
        break;
      }
      case "integer": {
        defaultSettings[input].value = v.replaceAll(/\D/g, "");
        console.log(
          chalk.bold(
            `${chalk.blue(
              defaultSettings[input].key
            )} has been set to: ${chalk.yellow(defaultSettings[input].value)}.`
          )
        );
        break;
      }
      case "float": {
        defaultSettings[input].value = v.replaceAll(/[^0-9.]/g, "");
        console.log(
          chalk.bold(
            `${chalk.blue(
              defaultSettings[input].key
            )} has been set to: ${chalk.yellow(defaultSettings[input].value)}.`
          )
        );
        break;
      }
      case "integer[any]": {
        defaultSettings[input].value = v.replaceAll(/[^0-9 ]/g, "");
        console.log(
          chalk.bold(
            `${chalk.blue(
              defaultSettings[input].key
            )} has been set to: ${chalk.yellow(defaultSettings[input].value)}.`
          )
        );
        break;
      }
      case "integer[2]": {
        v = v.replaceAll(/[^0-9\,]/g, "");
        if (!/^\d+,\d+$/.test(v)) {
          console.log(
            chalk.red.bold(
              "This is not a valid value for this type. Please try again."
            )
          );
          selectValue(input);
          return;
        }
        v = v.replace("{", "{ ").replace("}", " }").replace(",", ", ");
        defaultSettings[input].value = `{ ${v} }`;
        console.log(
          chalk.bold(
            `${chalk.blue(
              defaultSettings[input].key
            )} has been set to: ${chalk.yellow(defaultSettings[input].value)}.`
          )
        );
        break;
      }
      case "integer[3]": {
        v = v.replaceAll(/[^0-9\,]/g, "");
        if (!/^\d+,\d+,\d+$/.test(v)) {
          console.log(
            chalk.red.bold(
              "This is not a valid value for this type. Please try again."
            )
          );
          selectValue(input);
          return;
        }
        v = v.replace("{", "{ ").replace("}", " }").replaceAll(",", ", ");
        defaultSettings[input].value = `{ ${v} }`;
        console.log(
          chalk.bold(
            `${chalk.blue(
              defaultSettings[input].key
            )} has been set to: ${chalk.yellow(defaultSettings[input].value)}.`
          )
        );
        break;
      }
    }
    printSettingsTable();
    prompt();
  });
}

prompt();
