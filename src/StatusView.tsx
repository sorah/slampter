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
       <p>L {this.tickLocalString()}</p>
       <p>U {this.tickUtcString()}</p>
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

  public tickLocalString() {
    return moment(this.props.tick).format('HH:mm:ss');
  }

  public tickUtcString() {
    return moment(this.props.tick).utc().format('HH:mm:ss');
  }
}
