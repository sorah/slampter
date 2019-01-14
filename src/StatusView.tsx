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
    return <section className='status-view'>
      <div className='status-status'>
       {this.latency()}<br/>
       {this.lastUpdatedAgoString()}
      </div>
      <div className='status-time'>
        Local <span className='status-time-time'>{this.tickLocalString()}</span> UTC <span className='status-time-time'>{this.tickUtcString()}</span>
      </div>
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
