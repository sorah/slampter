import React from "react";

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
      <p>{this.timerString()}</p>
    </section>;
  }

  public timerString() {
    var duration = null;
    if (this.props.startTime && this.props.tick < this.props.startTime) {
      duration = this.props.startTime - this.props.tick;
    } else if (this.props.endTime && this.props.tick < this.props.endTime) {
      duration = this.props.endTime - this.props.tick;
    } else if (this.props.endTime && this.props.endTime < this.props.tick) {
      duration = this.props.tick - this.props.endTime;
    }

    if (duration) {
      return this.formatDuration(duration);
    } else {
      return "--:--:--";
    }
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
