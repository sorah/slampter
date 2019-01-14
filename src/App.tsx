import React from "react";
import PromptData from './PromptData';

import StatusView from './StatusView';
import TimerView from './TimerView';
import MessageView from './MessageView';

interface Props {
}

interface State {
  tick: number,
  tickDate: Date,
  lastDataUpdate: Date,
  promptData: PromptData,
}

export default class App extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      tick: -1,
      tickDate: new Date(),
      lastDataUpdate: new Date(),
      promptData: {
        ts: -1,
        st: -1,
        timer_start: null,
        timer_end: null,
        blink_end: null,
        message: null,
        headline: null,
      },
    };
  }

  public tick(date?: Date) {
    date = date || new Date();
    this.setState({tick: date.getTime(), tickDate: date});
  }

  public feedData(data: PromptData) {
    console.log(data);
    this.setState({
      lastDataUpdate: new Date(),
      promptData: data,
    });
    this.tick();
  }

  public render() {
    return <main>
      <StatusView
        tick={this.state.tickDate}
        serverTime={new Date(this.state.promptData.st)}
        lastUpdatedTime={new Date(this.state.promptData.ts * 1000)}
        lastFetchTime={this.state.lastDataUpdate}
      />
      <TimerView
        tick={this.state.tick / 1000}
        headline={this.state.promptData.headline || ''}
        startTime={this.state.promptData.timer_start}
        endTime={this.state.promptData.timer_end}
      />
      <MessageView
        tick={this.state.tick / 1000}
        message={this.state.promptData.message || ''}
        blinkEndTime={this.state.promptData.blink_end}
      />
    </main>;
  }
}

