import React from "react";

interface Props {
  message: string,
  blinkEndTime: number | null,
}
interface State {
}

export default class MessageView extends React.Component<Props, State> {
  public render() {
    return <section className='message-view'>
      <p>{this.props.message}</p>
    </section>
  }
}
