// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

import("../../assets/stylesheets/application.css");
import("bulma/css/bulma.css");
import "../styles/background";
