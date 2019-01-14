import React from "react";

enum TimerStatus {
  Off = 'off',
  Standby = 'standby',
  Running = 'running',
  Overrun = 'overrun',
}

interface Props {
  tick: number,
  headline: string,
  startTime: number | null,
  endTime: number | null,
}
interface State {
}

export default class TimerView extends React.Component<Props, State> {
  public render() {
    return <section className={`timer-view timer-view_${this.timerStatus()}`}>
      <p className='headline'>{this.props.headline}</p>
      <div className='timer'>
        <div className='timer-left'>

          <div className='timer-mean'>
            <span className='timer-status--show timer-status--show-standby'>Starting in:</span>
            <span className='timer-status--show timer-status--show-running'>Time remaining:</span>
            <span className='timer-status--show timer-status--show-overrun'>Exceeding:</span>
          </div>
          <div className='timer-status'>
            <div className='timer-status-text timer-status--show timer-status--show-off'>Off</div>
            <div className='timer-status-text timer-status--show timer-status--show-standby'>STANDBY</div>
            <div className='timer-status-text timer-status--show timer-status--show-running'>LIVE</div>
            <div className='timer-status-text timer-status--show timer-status--show-overrun'>OVER</div>
          </div>
        </div>
        <div>
          <div className='timer-display'>
            {this.timerString()}
          </div>
        </div>
      </div>
    </section>;
  }

  public timerString() {
    var duration = null;
    const timerStatus = this.timerStatus();
    switch (timerStatus) {
      case TimerStatus.Standby:
        duration = this.props.startTime && this.props.startTime - this.props.tick;
        break;
      case TimerStatus.Running:
        duration = this.props.endTime && this.props.endTime - this.props.tick;
        break;
      case TimerStatus.Overrun:
        duration = this.props.endTime && this.props.tick - this.props.endTime;
        break;
    }

    if (duration) {
      return this.formatDuration(duration);
    } else {
      return "--:--:--";
    }
  }

  public timerStatus() {
    if (this.props.startTime && this.props.tick < this.props.startTime) {
      return TimerStatus.Standby;
    } else if (this.props.endTime && this.props.tick < this.props.endTime) {
      return TimerStatus.Running;
    } else if (this.props.endTime && this.props.endTime < this.props.tick) {
      return TimerStatus.Overrun;
    }
    return TimerStatus.Off;
  }

  private formatDuration(duration: number) {
    var s = duration;

    const h = Math.trunc(s / 3600);
    var s = s % 3600;

    const m = Math.trunc(s / 60);
    var s = Math.floor(s % 60);

    const hStr = h < 10 ? `0${h}` : h.toString();
    const mStr = m < 10 ? `0${m}` : m.toString();
    const sStr = s < 10 ? `0${s}` : s.toString();

    return `${hStr}:${mStr}:${sStr}`;
  }
}
