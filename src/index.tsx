import React from "react";
import ReactDOM from "react-dom";

import App from './App';

document.addEventListener("DOMContentLoaded", () => {
  const elem = document.getElementById('container');
  const component = ReactDOM.render(
    <App />,
    elem,
  ) as App;

  setInterval(() => component.tick(), 500);

  const dataUrl = location.pathname.replace(/^\/p\//,'/data/');
  const fetchData = async function() {
    try {
      const response = await fetch(dataUrl, {credentials: 'include', cache: "no-cache"});
      if (!response.ok) throw new Error(`response not ok: ${response.status}`);
      const json = await response.json();

      component.feedData(json);
    } catch (e) {
      console.log(e);
      return false;
    }
    return true;
  };

  const fetchDataLoop = async function() {
    const startTime = new Date().getTime();
    const result = await fetchData();
    const endTime = new Date().getTime();
    var interval = 1000 - (endTime - startTime);
    if (interval < 0) {
      interval = 1;
    }
    if (!result) {
      interval = 2000;
    }
    setTimeout(fetchDataLoop, interval);
  };

  fetchDataLoop();
});
