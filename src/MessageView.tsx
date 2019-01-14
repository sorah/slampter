import React from "react";

interface Props {
  tick: number,
  message: string,
  blinkEndTime: number | null,
}
interface State {
}

export default class MessageView extends React.Component<Props, State> {
  public render() {
    return <section className={`message-view ${this.blinking() ? 'message-view-blink' : ''}`}>
      <p>{this.props.message}</p>
    </section>
  }

  public blinking() {
    return this.props.blinkEndTime && this.props.tick < this.props.blinkEndTime;
  }
}
