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
      log.e('current embed node is not table: %s', node?.type);
      return undefined;
    }
    return node;
  }
  private reload() {
    const tableNode = this.node;
    if (tableNode) {
      const table = new DSTable();
      let row: DSTableRow = new DSTableRow();

      tableNode.children.forEach(child => {
        child.children.forEach(_row => {
          const tr = new DSTableRow(_row as TableItem, table);
          table.rows.push(tr);
          row = tr;
          _row.children.forEach(_cell => {
            const item = _cell as TableItem;
            if (item.itemType === ETableItem.TH) {
              const th = new DSTableCell(row, item, table);
              row.cells.push(th);
              table.cells[th.ref] = new WeakRef(th);
            } else if (item.itemType === ETableItem.TD) {
              const td = new DSTableCell(row, item, table);
              row.cells.push(td);
              table.cells[td.ref] = new WeakRef(td);
            }
          });
        });
      });
      this.table = table;
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
          ContentBoxBar.copyAction(undefined, this.sharedEngine),
          // ContentBoxBar.openAction(undefined, this.sharedEngine),
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
        this.styledEmbed?.componentAreaChange(oldValue, newValue);
        this.table.onAreaChange(oldValue, newValue);
      })
      .visibility(this.table.ready ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  TableContent() {
    List() {
      ForEach(this.table.rows, (row: DSTableRow) => {
        if (row.parent?.itemType === ETableItem.Head) {
          //  Table TH
          ListItem() {
            this.TableRow(row, [new StyledTextValue(this.theme.table?.headerFont)])
          }
          .backgroundColor(this.theme.table?.headerBackgroundColor)
        } else {
          //  Table TD
          ListItem() {
            this.TableRow(row, [new StyledTextValue(this.theme.table?.contentFont)])
          }
        }
      }, (row: DSTableRow) => row.likelyKey)
    }
  }
  @Builder
  TableRow(row: DSTableRow, styles?: StyledValue[]) {
    Row() {
      ForEach(row.cells, (cell: DSTableCell) => {
        Row() {
          EmbedComponent({
            node: cell.node?.deref(),
            area: { width: this.theme.table?.cellMaxWidth },
            styles,
          })
            .constraintSize(cell.constraintSize(this.styledEmbed.blockArea, this.theme))
            .width(cell.width)
            .height(cell.height)
            .onAreaChange((oldValue, newValue) => {
              cell.width = newValue.width;
              cell.height = newValue.height;
              cell.table?.deref()?.cellAreaChange(cell, oldValue, newValue);
            })
        }
        .padding(this.theme.contentBox?.barMargin ? MDMargin.lengthMargin(this.theme.contentBox?.barMargin) : undefined)
        .borderWidth(cell.borderWidth(this.theme))
        .borderColor(this.theme.contentBox?.border?.color)
      }, (cell: DSTableCell) => cell.likelyKey)
    }
  }
}

/**
 * DataSource for Table
 */

@ObservedV2
class DSTable {
  rows: DSTableRow[] = [];
  cells: Record<DSTableCellRef, WeakRef<DSTableCell>> = {};
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
        if (ele.height !== undefined) {
          ele.height = maxHeight;
        }
      });
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
            if (column.width !== undefined) {
              column.width = maxWidth;
            }
          }
        });
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
    this.ready = allCellReady;
  }
  get summary(): IDSTableMeta {
    return {
      rows: this.rows.map(ele => ele.summary),
    };
  }
}
class DSTableRow {
  table?: WeakRef<DSTable>;
  node?: WeakRef<TableItem>;
  cells: DSTableCell[] = [];
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
      index: this.index,
      cells: this.cells.map(ele => ele.summary),
    };
  }
  get likelyKey(): string | undefined {
    return this.node?.deref() ? `${this.index}_${this.node?.deref()?.hash}` : undefined;
  }
}
type DSTableCellRef = string;
@ObservedV2
class DSTableCell {
  table?: WeakRef<DSTable>;
  node?: WeakRef<TableItem>;
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
      index: this.index,
      width: this.width,
      height: this.height,
    };
  }
  get ref(): DSTableCellRef {
    return `${this.row.deref()?.index ?? -1}:${this.index ?? -1}`;
  }
  get likelyKey(): string | undefined {
    return this.node?.deref() ? `${this.ref}_${this.node?.deref()?.hash}` : undefined;
  }
}

interface IDSTableMeta {
  rows: IDSTableRowMeta[];
}
interface IDSTableRowMeta {
  index?: number;
  cells: IDSTableCellMeta[];
}
interface IDSTableCellMeta {
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