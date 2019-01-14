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
    return <section>
      <p>{this.props.headline}</p>
      <p>{this.timerStatus()}</p>
      <p>{this.timerString()}</p>
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
