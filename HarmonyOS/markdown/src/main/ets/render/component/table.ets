// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { K_COMPONENT, MDLength, IMDArea, newLog, MDMargin, MDArea } from '../../util';
import { Engine, BaseEngine } from '../../engine';
import { ITheme } from '../../theme';
import {
  StyledEmbed, StyledTextValue, type StyledValue,
} from '../styled';
import { ENode, TableItem, ETableItem } from '../../service/ast/node';
import { EmbedComponent } from './embed';
import { ContentBoxComponent, ContentBoxBar, type IContentBoxAction, IContentBoxBar } from './content-box';

const log = newLog('TableComponent');

@ComponentV2
export struct FSTableComponent {
  private _gid: number = FSTableComponent.getGID();
  private static gid: number = 0;

  private static getGID() {
    return FSTableComponent.gid++;
  }

  get ID() {
    return this._gid;
  }

  @Require @Param @Once styledEmbed: StyledEmbed;
  @Require @Param @Once engine: Engine = new BaseEngine();

  @Provider(K_COMPONENT.THEME) theme: ITheme = this.engine.theme!.theme;
  @Provider(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = this.engine;

  @Local table: DSTable = new DSTable();
  @Local box_width: Length = 0
  @Local box_height: Length = 0
  @Local table_h: Length = 99999
  @Local table_w: Length = 99999
  @Local ready: boolean = false

  private get node() {
    const node = this.styledEmbed.node;
    if (!node || !node.is(ENode.Table)) {
      log.e(`current embed node is not table: ${node?.type}`);
      return undefined;
    }
    return node;
  }

  private reload() {
    const tableNode = this.node;
    if (tableNode) {
      log.d(`component ${this.ID} table ${this.table.ID} reload start: ${JSON.stringify(this.table.summary)}`);
      const dequeueRow = (rowIndex: number, rowItem: TableItem) => {
        let row = this.table.rows.slice(rowIndex, rowIndex + 1).pop();
        if (!row) {
          row = new DSTableRow(rowItem, this.table);
          this.table.rows.push(row);
        } else {
          row.node = new WeakRef(rowItem);
        }
        return row;
      };
      const dequeueCell = (rowIndex: number, cellIndex: number, rowItem: TableItem, cellItem: TableItem) => {
        const row = dequeueRow(rowIndex, rowItem);
        let cell = row.cells.slice(cellIndex, cellIndex + 1).pop();
        if (!cell) {
          cell = new DSTableCell(row, cellItem, this.table);
          row.cells.push(cell);
        } else {
          cell.node = new WeakRef(cellItem);
        }
        return cell;
      };

      const rows: TableItem[] = [];
      tableNode.children.forEach(child => {
        //  thead | tbody
        child.children.forEach(item => {
          //  tr
          rows.push(item as TableItem);
        });
      });
      rows.forEach((row, rowIndex) => {
        dequeueRow(rowIndex, row as TableItem);
        row.children.forEach((cell, cellIndex) => {
          dequeueCell(rowIndex, cellIndex, row as TableItem, cell as TableItem);
        });
      });

      log.d(`component ${this.ID} table ${this.table.ID} reload end: ${JSON.stringify(this.table.summary)}`);
    }
  }

  aboutToAppear(): void {
    this.reload()
  }

  build() {
    Row() {
      List() {
        if (this.ready) {
          ListItem() {
            List() {
              ListItem() {
                Column() {
                  ForEach(this.table?.rows, (row: DSTableRow) => {
                    Row() {
                      ForEach(row.cells, (cell: DSTableCell) => {
                        Row() {
                          EmbedComponent({
                            node: cell.node?.deref(),
                            area: { width: this.theme.table?.cellMaxWidth },
                            styles: [new StyledTextValue(row.parent?.itemType === ETableItem.Head ?
                              this.theme.table?.headerFont :
                              this.theme.table?.contentFont)]
                          })
                          // .constraintSize(cell.constraintSize(this.styledEmbed.blockArea, this.theme))
                            .width(cell.width)
                            .height(cell.height)
                            .onAreaChange((oldValue, newValue) => {
                              cell.width = newValue.width;
                              cell.height = newValue.height;
                              cell.table?.deref()?.cellAreaChange(cell, oldValue, newValue);
                            })
                        }
                        .padding(this.theme.contentBox?.barMargin ?
                          MDMargin.lengthMargin(this.theme.contentBox?.barMargin) :
                          undefined)
                        .borderWidth(cell.borderWidth(this.theme))
                        .borderColor(this.theme.contentBox?.border?.color)
                        .layoutWeight((this.table_w <= this.box_width) ? (cell.width as number) : undefined)

                        // .height((this.table_h <= this.box_height) ? "100%" : undefined)
                      }, (cell: DSTableCell) => cell.likelyKey)
                    }
                    .backgroundColor(row.parent?.itemType === ETableItem.Head ?
                      this.theme.table?.headerBackgroundColor :
                      null)

                    // .layoutWeight((this.table_h <= this.box_height) ? 1 : null)
                  }, (row: DSTableRow) => row.likelyKey)
                }
                .border({
                  width: MDLength.metrics2length(this.theme.contentBox?.border?.width ?? MDLength.vp(0)),
                  color: this.theme.contentBox?.border?.color,
                  radius: MDLength.metrics2length(this.theme.contentBox?.border?.radius ?? MDLength.vp(0)),
                  style: BorderStyle.Solid,
                })
                .clip(true)
                .onAreaChange((oldValue, newValue) => {
                  this.table_h = newValue.height
                  this.table_w = newValue.width
                })
              }
            }
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
          }

          // .height((this.table_h <= this.box_height) ? "100%" : null)
        }
      }
      .scrollBar(BarState.Off)
    }
    .height("100%")
    .width("100%")
    .onAreaChange((oldValue, newValue) => {
      if (newValue.height < newValue.width) {
        this.box_width = newValue.width
        this.box_height = newValue.height
        this.ready = true
      }
    })
  }
}

@ComponentV2
export struct TableComponent {
  private _gid: number = TableComponent.getGID();
  private static gid: number = 0;
  private static getGID() {
    return TableComponent.gid++;
  }
  get ID() {
    return this._gid;
  }

  @Consumer(K_COMPONENT.THEME) theme: ITheme = {};
  @Consumer(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = new BaseEngine();

  @Require @Param @Once styledEmbed: StyledEmbed;
  @Local table: DSTable = new DSTable();

  @Monitor('styledEmbed') onStyledEmbedChange(monitor: IMonitor) {
    const embed = monitor.value<StyledEmbed>();
    if (embed?.before || embed?.now) {
      if (embed?.before?.option.styled.node?.hash !== embed?.now?.option.styled.node?.hash) {
        this.reload();
      }
    }
  }

  private bridge: TableComponentBridge = new TableComponentBridge({
    styledEmbed: () => this.styledEmbed,
  });

  private barOption?: IContentBoxBar;
  private currentArea?: IMDArea;

  private get node() {
    const node = this.styledEmbed.node;
    if (!node || !node.is(ENode.Table)) {
      log.e(`current embed node is not table: ${node?.type}`);
      return undefined;
    }
    return node;
  }
  private reload() {
    const tableNode = this.node;
    if (tableNode) {
      log.d(`component ${this.ID} table ${this.table.ID} reload start: ${JSON.stringify(this.table.summary)}`);
      const dequeueRow = (rowIndex: number, rowItem: TableItem) => {
        let row = this.table.rows.slice(rowIndex, rowIndex + 1).pop();
        if (!row) {
          row = new DSTableRow(rowItem, this.table);
          this.table.rows.push(row);
        } else {
          row.node = new WeakRef(rowItem);
        }
        return row;
      };
      const dequeueCell = (rowIndex: number, cellIndex: number, rowItem: TableItem, cellItem: TableItem) => {
        const row = dequeueRow(rowIndex, rowItem);
        let cell = row.cells.slice(cellIndex, cellIndex + 1).pop();
        if (!cell) {
          cell = new DSTableCell(row, cellItem, this.table);
          row.cells.push(cell);
        } else {
          cell.node = new WeakRef(cellItem);
        }
        return cell;
      };

      const rows: TableItem[] = [];
      tableNode.children.forEach(child => {
        //  thead | tbody
        child.children.forEach(item => {
          //  tr
          rows.push(item as TableItem);
        });
      });
      rows.forEach((row, rowIndex) => {
        dequeueRow(rowIndex, row as TableItem);
        row.children.forEach((cell, cellIndex) => {
          dequeueCell(rowIndex, cellIndex, row as TableItem, cell as TableItem);
        });
      });

      log.d(`component ${this.ID} table ${this.table.ID} reload end: ${JSON.stringify(this.table.summary)}`);
    }
  }
  aboutToAppear(): void {
    this.styledEmbed.embedController.updateEmbed = embed => {
      this.styledEmbed = embed;
    };
    this.styledEmbed.embedController.currentArea = () => {
      return this.currentArea;
    };
    this.barOption = this.sharedEngine.event!.invokeTableBarOption({ bridge: this.bridge });
    this.reload();
  }

  build() {
    ContentBoxComponent({
      content: () => { this.TableContent() },
      bar: {
        title: this.barOption?.title ?? '表格',
        actions: this.barOption?.actions ?? [
          // ContentBoxBar.copyAction(undefined, this.sharedEngine),
          ContentBoxBar.openAction(undefined, this.sharedEngine),
        ],
      },
      onActionClick: (action, event) => {
        this.sharedEngine.event!.invokeTableActionClick({
          bridge: this.bridge,
          action, event,
        });
      },
    })
      .position(this.styledEmbed?.position)
      .onAreaChange((oldValue, newValue) => {
        this.currentArea = MDArea.area(newValue);
        if (!MDArea.mdAreaEqual(MDArea.area(oldValue), MDArea.area(newValue))) {
          this.styledEmbed?.componentAreaChange(oldValue, newValue);
        }
        this.table.onAreaChange(oldValue, newValue);
        // log.d(`component ${this.ID} table ${this.table.ID} AreaChange (${newValue.width},${newValue.height}) ${JSON.stringify(this.table.summary)}`);
      })
      .visibility(this.table.ready ? Visibility.Visible : Visibility.Hidden)
      .width(this.styledEmbed?.initMetrics.width)
  }

  @Builder
  TableContent() {
    List() {
      ForEach(this.table.rows, (row: DSTableRow) => {
        if (row.parent?.itemType === ETableItem.Head) {
          //  Table TH
          ListItem() {
            this.TableRow({ row, styles: [new StyledTextValue(this.theme.table?.headerFont)] })
          }
          .backgroundColor(this.theme.table?.headerBackgroundColor)
        } else {
          //  Table TD
          ListItem() {
            this.TableRow({ row, styles: [new StyledTextValue(this.theme.table?.contentFont)] })
          }
        }
      }, (row: DSTableRow) => row.likelyKey)
    }
  }
  @Builder
  TableRow(data: ITableRowData) {
    Row() {
      ForEach(data.row.cells, (cell: DSTableCell) => {
        Row() {
          Scroll() {
            EmbedComponent({
              node: cell.node?.deref(),
              area: { width: this.theme.table?.cellMaxWidth },
              styles: data.styles,
              needStack: false,
            })
              .constraintSize(cell.constraintSize(this.styledEmbed.blockArea, this.theme))
              .onAreaChange((oldValue, newValue) => {
                if (MDArea.mdAreaEqual(MDArea.area(oldValue), MDArea.area(newValue))) {
                  return;
                }
                cell.table?.deref()?.cellAreaChange(cell, oldValue, newValue);
                // log.d(`component ${this.ID} table ${this.table.ID} Cell ${cell.likelyKey} ${cell.ID} t ${cell.table?.deref()?.ID} AreaChange (${newValue.width},${newValue.height}) ${JSON.stringify(cell.summary)}`);
              })
          }
          .align(Alignment.TopStart)
          .scrollable(ScrollDirection.None)
          .constraintSize({ minWidth: cell.width, minHeight: cell.height })
        }
        .padding(this.theme.contentBox?.barMargin ? MDMargin.lengthMargin(this.theme.contentBox?.barMargin) : undefined)
        .borderWidth(cell.borderWidth(this.theme))
        .borderColor(this.theme.contentBox?.border?.color)
      }, (cell: DSTableCell) => cell.likelyKey)
    }
  }
}
interface ITableRowData {
  row: DSTableRow;
  styles?: StyledValue[];
}

/**
 * DataSource for Table
 */

@ObservedV2
class DSTable {
  private static gid: number = 0;
  private static createGID() {
    return DSTable.gid++;
  }
  readonly ID: number = DSTable.createGID();

  @Trace rows: DSTableRow[] = [];
  @Trace ready: boolean = false;

  cellAreaChange(cell: DSTableCell, _oldValue: Area, newValue: Area) {
    //  re-layout row
    do {
      let maxHeight: Length = newValue.height;
      cell.row.deref()?.cells.forEach(ele => {
        if (ele.height !== undefined && ele.height > maxHeight) {
          maxHeight = ele.height;
        }
      });
      cell.row.deref()?.cells.forEach(ele => {
        if (ele.height !== undefined && ele.height !== maxHeight) {
          ele.height = maxHeight;
        }
      });
      if (cell.height === undefined) {
        cell.height = maxHeight;
      }
      log.d(`table ${this.ID} relayout row maxHeight ${maxHeight} cell ${cell.ID} ${cell.likelyKey}`);
    } while (0);
    //  re-layout column
    do {
      let maxWidth: Length = newValue.width;
      const index = cell.index;
      if (index !== undefined) {
        this.rows.forEach(row => {
          if (row.cells.length > index) {
            const column = row.cells[index];
            if (column.width !== undefined && column.width > maxWidth) {
              maxWidth = column.width;
            }
          }
        });
        this.rows.forEach(row => {
          if (row.cells.length > index) {
            const column = row.cells[index];
            if (column.width !== undefined && column.width !== maxWidth) {
              column.width = maxWidth;
            }
          }
        });
        if (cell.width === undefined) {
          cell.width = maxWidth;
        }
        log.d(`table ${this.ID} relayout column maxWidth ${maxWidth} cell ${cell.ID} ${cell.likelyKey}`);
      }
    } while (0);
  }
  onAreaChange(_oldValue: Area, _newValue: Area) {
    let allCellReady: boolean = true;
    this.rows.forEach(row => {
      row.cells.forEach(cell => {
        if (cell.width === undefined || cell.height === undefined) {
          allCellReady = false;
        }
      });
    });
    if (this.ready !== allCellReady) {
      if (this.ready === false) {
        this.ready = allCellReady;
      }
    }
  }
  get summary(): IDSTableMeta {
    return {
      id: this.ID,
      rows: this.rows.map(ele => ele.summary),
      ready: this.ready,
    };
  }
}

@ObservedV2
class DSTableRow {
  private static gid: number = 0;
  private static createGID() {
    return DSTableRow.gid++;
  }
  readonly ID: number = DSTableRow.createGID();

  @Trace cells: DSTableCell[] = [];
  table?: WeakRef<DSTable>;
  node?: WeakRef<TableItem>;
  constructor(node?: TableItem, table?: DSTable) {
    if (node) {
      this.node = new WeakRef(node);
    }
    if (table) {
      this.table = new WeakRef(table);
    }
  }
  get index(): number | undefined {
    return this.table?.deref()?.rows.indexOf(this);
  }
  get parent(): TableItem | undefined {
    const parent = this.node?.deref()?.parent?.deref();
    if (parent?.is(ENode.TableItem)) {
      return parent as TableItem;
    }
    return undefined;
  }
  get summary(): IDSTableRowMeta {
    return {
      id: this.ID,
      index: this.index,
      cells: this.cells.map(ele => ele.summary),
    };
  }
  get likelyKey(): string | undefined {
    return `row:${this.index}`;
  }
}
type DSTableCellRef = string;
@ObservedV2
class DSTableCell {
  private static gid: number = 0;
  private static createGID() {
    return DSTableCell.gid++;
  }
  readonly ID: number = DSTableCell.createGID();

  @Trace node?: WeakRef<TableItem>;
  table?: WeakRef<DSTable>;
  row: WeakRef<DSTableRow>;

  @Trace width?: Length;
  @Trace height?: Length;

  constructor(row: DSTableRow, node?: TableItem, table?: DSTable) {
    this.row = new WeakRef(row);
    if (node) {
      this.node = new WeakRef(node);
    }
    if (table) {
      this.table = new WeakRef(table);
    }
  }
  isEmpty() {
    return !this.node;
  }
  constraintSize(area?: IMDArea, theme?: ITheme): ConstraintSizeOptions {
    const length = this.row.deref()?.cells.length ?? 0;
    const marginWidth = MDLength.vp(
      (theme?.contentBox?.barMargin?.left?.value ?? 0) +
        (theme?.contentBox?.barMargin?.right?.value ?? 0)
    )
    const borderWidth = MDLength.vp(theme?.contentBox?.border?.width?.value ?? 0);
    //  border_count = cell_left ( length - 1 ) + table_left_right ( 1 + 1 ) = length + 1
    let width = MDLength.vp((area?.width?.value ?? 0) - marginWidth.value * length - borderWidth.value * (length + 1));
    let minWidth: LengthMetrics = MDLength.vp(width.value / (length || 1));
    let maxWidth: LengthMetrics = this.index === 0 ?
      theme?.table?.cellMaxWidth4First ?? MDLength.vp(0) :
      theme?.table?.cellMaxWidth ?? MDLength.vp(0);
    maxWidth = MDLength.vp(maxWidth.value - marginWidth.value - borderWidth.value);
    if (maxWidth.value < minWidth.value) {
      maxWidth = minWidth;
    }
    if (length === 1) {
      return {
        minWidth: minWidth.value > 0 ? MDLength.metrics2length(minWidth) : undefined,
      };
    } else {
      return {
        maxWidth: maxWidth.value > 0 ? MDLength.metrics2length(maxWidth) : undefined,
        minWidth: minWidth.value > 0 ? MDLength.metrics2length(minWidth) : undefined,
      };
    }
  }
  borderWidth(theme?: ITheme): EdgeWidths {
    const width = MDLength.metrics2length(
      theme?.contentBox?.border?.width ??
      MDLength.vp(0)
    );
    return {
      top: width,
      left: this.index !== 0 ? width : undefined,
    };
  }
  get index(): number | undefined {
    return this.row.deref()?.cells.indexOf(this);
  }
  get summary(): IDSTableCellMeta {
    return {
      id: this.ID,
      index: this.index,
      width: this.width,
      height: this.height,
    };
  }
  get ref(): DSTableCellRef {
    return `${this.row.deref()?.index ?? -1}:${this.index ?? -1}`;
  }
  get likelyKey(): string | undefined {
    return `row:${this.row?.deref()?.index}_cell:${this.index}`;
  }
}

interface IDSTableMeta {
  id: number;
  rows: IDSTableRowMeta[];
  ready: boolean;
}
interface IDSTableRowMeta {
  id: number;
  index?: number;
  cells: IDSTableCellMeta[];
}
interface IDSTableCellMeta {
  id: number;
  index?: number;
  width?: Length;
  height?: Length;
}

/**
 * Event
 */

interface ITableComponentBridge {
  styledEmbed: () => StyledEmbed,
}
export class TableComponentBridge {
  private option: ITableComponentBridge;
  constructor(option: ITableComponentBridge) {
    this.option = option;
  }
  get styledEmbed() {
    return this.option.styledEmbed();
  }
}
export interface ITableComponentEvent {
  bridge: TableComponentBridge;
}
export interface ITableComponentActionClickEvent extends ITableComponentEvent {
  action: IContentBoxAction,
  event: ClickEvent,
}