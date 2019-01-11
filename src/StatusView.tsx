import React from "react";
import * as moment from "moment";

interface Props {
  tick: Date,
  lastFetchTime: Date,
  serverTime: Date,
  lastUpdatedTime: Date,
}
interface State {
}

export default class StatusView extends React.Component<Props, State> {
  public render() {
    return <section>
       <p>{this.props.tick.toString()}</p>
       <p>{this.latency()}</p>
       <p>{this.lastUpdatedAgoString()}</p>
    </section>;
  }

  public latency() {
    return this.props.lastFetchTime.getTime() - this.props.serverTime.getTime();
  }

  public lastUpdatedAgoString() {
    return moment(this.props.lastUpdatedTime).fromNow();
  }
}
